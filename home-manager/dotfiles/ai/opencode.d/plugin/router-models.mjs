// OpenCode plugin: auto-discover 9router models from /v1/models API
// Self-contained, zero deps.

/** @returns {import("@opencode-ai/plugin").PluginHooks} */
export default async () => ({
  provider: {
    id: "9router",
    models: async (provider) => {
      const baseURL = /** @type {string|undefined} */ (provider.options?.baseURL);
      const apiKey  = provider.key ?? /** @type {string|undefined} */ (provider.options?.apiKey);

      if (!baseURL || !apiKey) {
        console.warn("router-models: no baseURL or apiKey on provider");
        return {};
      }

      // Build models URL — /v1/models relative to baseURL
      let modelsUrl;
      try {
        modelsUrl = new URL("./models", baseURL.endsWith("/") ? baseURL : baseURL + "/").href;
      } catch {
        modelsUrl = `${baseURL.replace(/\/?$/, "")}/models`;
      }

      /** @type {{ data?: Array<{id:string, capabilities?:Record<string,unknown>}> }} */
      let data;
      try {
        const res = await fetch(modelsUrl, {
          headers: { Authorization: `Bearer ${apiKey}` },
        });
        if (!res.ok) {
          console.warn(`router-models: API ${res.status} ${res.statusText}`);
          return {};
        }
        data = await res.json();
      } catch (err) {
        console.warn("router-models: fetch failed", err);
        return {};
      }

      if (!data?.data) return {};

      /** @type {Record<string, import("@opencode-ai/plugin").ModelV2>} */
      const models = {};
      for (const m of data.data) {
        if (!m.id) continue;
        const c = m.capabilities ?? {};
        const hasVision = !!c.vision;
        const hasTools  = !!c.tools;
        const hasReason = !!c.reasoning;
        const ctxWin    = Number(c.contextWindow) || 128_000;
        const maxOut    = Number(c.maxOutput) || 16_384;

        models[m.id] = {
          id: m.id,
          name: m.id,
          capabilities: {
            temperature: true,
            reasoning: hasReason,
            attachment: hasVision,
            toolcall: hasTools,
            interleaved: hasReason,
            input: {
              text: true,
              audio: false,
              image: hasVision,
              video: false,
              pdf: hasVision,
            },
            output: { text: true, audio: false, image: false, video: false, pdf: false },
          },
          cost: { input: 0, output: 0, cache: { read: 0, write: 0 } },
          limit: { context: ctxWin, output: maxOut },
          status: "active",
        };
      }
      return models;
    },
  },
});
