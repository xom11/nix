// OpenCode plugin: inject 9router models from /v1/models API into config
// Self-contained, zero deps.
// Uses config() hook — reliable, runs before provider init.

export default async () => ({
  config: async (cfg) => {
    const routerCfg = cfg?.provider?.["9router"];
    if (!routerCfg) return;

    const baseURL = routerCfg.options?.baseURL;
    const apiKey  = routerCfg.options?.apiKey;
    if (!baseURL || !apiKey) return;

    const resolve = (s) =>
      typeof s === "string"
        ? s.replace(/\{env:([^}]+)\}/g, (_, name) => process.env[name] ?? "")
        : s;

    const resolvedURL = resolve(baseURL);
    const resolvedKey = resolve(apiKey);
    if (!resolvedURL || !resolvedKey) return;

    // ── Fallback models: always available ──
    const fallback = ["combo1", "combo2", "taoxyz"];
    routerCfg.models = {};
    for (const id of fallback) {
      routerCfg.models[id] = {
        name: id,
        modalities: { input: ["text", "image"], output: ["text"] },
      };
    }

    // ── Fetch full model list from API ──
    const modelsUrl = resolvedURL.endsWith("/")
      ? `${resolvedURL}models`
      : `${resolvedURL}/models`;

    /** @type {{ data?: Array<{id:string, capabilities?:Record<string,unknown>}> }} */
    let data;
    try {
      const res = await fetch(modelsUrl, {
        headers: { Authorization: `Bearer ${resolvedKey}` },
      });
      if (!res.ok) return;
      data = await res.json();
    } catch {
      return; // network error — keep fallback models
    }
    if (!data?.data) return;

    // Replace fallback with full API list
    for (const m of data.data) {
      if (!m.id) continue;
      const c = m.capabilities ?? {};
      const input = ["text"];
      if (c.vision) input.push("image");
      routerCfg.models[m.id] = {
        name: m.id,
        modalities: { input, output: ["text"] },
      };
    }
  },
});
