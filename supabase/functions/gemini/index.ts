// deno-lint-ignore-file no-explicit-any
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

serve(async (req: Request) => {
  try {
    const { prompt, deviceId, stream } = await req.json().catch(() => ({}) as any);

    if (!prompt || typeof prompt !== "string") {
      return new Response(JSON.stringify({ error: "bad_request", message: "No prompt provided" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return new Response(JSON.stringify({ error: "missing_key", message: "Missing GEMINI_API_KEY" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    const sysInstruction =
      "Return only the requested text in strict plain text. Do not add any explanations, prefixes, suffixes, or extra context. Preserve all line breaks, tabs, and whitespace exactly as produced. No markdown fences, no labels, no commentary. Output only the content.";

    if (stream === true) {
      // Streaming mode: forward Gemini SSE into NDJSON { delta: "..." } chunks and a final { text: "..." }
      const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:streamGenerateContent?alt=sse";
      const body = {
        system_instruction: { parts: [{ text: sysInstruction }] },
        generationConfig: { responseMimeType: "text/plain" },
        contents: [
          {
            parts: [{ text: prompt }],
          },
        ],
      };

      const upstream = await fetch(url, {
        method: "POST",
        headers: {
          "x-goog-api-key": apiKey,
          "Content-Type": "application/json",
          Accept: "text/event-stream",
        },
        body: JSON.stringify(body),
      });

      if (!upstream.ok || !upstream.body) {
        const errText = await upstream.text().catch(() => "");
        return new Response(JSON.stringify({ error: "upstream_error", message: errText || upstream.statusText }), {
          status: upstream.status || 500,
          headers: { "Content-Type": "application/json" },
        });
      }

      const reader = upstream.body.getReader();
      const encoder = new TextEncoder();
      const decoder = new TextDecoder();
      let accumulated = "";

      const streamOut = new ReadableStream<Uint8Array>({
        async pull(ctrl) {
          const { value, done } = await reader.read();
          if (done) {
            // Emit a final consolidated text object
            if (accumulated.length > 0) {
              ctrl.enqueue(encoder.encode(JSON.stringify({ text: accumulated }) + "\n"));
            }
            ctrl.close();
            return;
          }
          const chunk = decoder.decode(value, { stream: true });
          for (const rawLine of chunk.split("\n")) {
            const line = rawLine.trim();
            if (!line || line.startsWith(":")) continue;
            if (line.startsWith("data:")) {
              const payload = line.slice(5).trim();
              if (payload === "[DONE]") continue;
              try {
                const json = JSON.parse(payload);
                const piece: string = json?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
                if (piece) {
                  accumulated += piece;
                  ctrl.enqueue(encoder.encode(JSON.stringify({ delta: piece }) + "\n"));
                }
              } catch {
                // ignore malformed lines
              }
            }
          }
        },
      });

      return new Response(streamOut, {
        status: 200,
        headers: {
          "Content-Type": "application/x-ndjson; charset=utf-8",
          "Cache-Control": "no-cache",
          "Transfer-Encoding": "chunked",
        },
      });
    }

    // Non-streaming: single plain text body
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=${apiKey}`;
    const requestBody = {
      system_instruction: { parts: [{ text: sysInstruction }] },
      generationConfig: { responseMimeType: "text/plain" },
      contents: [
        {
          parts: [{ text: prompt }],
        },
      ],
    };

    const geminiRes = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(requestBody),
    });

    if (!geminiRes.ok) {
      const errText = await geminiRes.text();
      return new Response(errText, { status: geminiRes.status });
    }

    const result = await geminiRes.json();
    const outputText: string = result?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

    return new Response(outputText, {
      status: 200,
      headers: {
        "Content-Type": "text/plain; charset=utf-8",
        "Cache-Control": "no-cache",
      },
    });
  } catch (err: any) {
    const msg = typeof err?.message === "string" ? err.message : "Unknown error";
    return new Response(JSON.stringify({ error: "internal", message: msg }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});