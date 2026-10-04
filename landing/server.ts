import home from "./index.html";
import privacy from "./privacy.html";
import license from "./license.html";

Bun.serve({
  port: Number(process.env.PORT ?? 4321),
  development: true,
  routes: {
    "/": home,
    "/index.html": home,
    "/privacy": privacy,
    "/privacy.html": privacy,
    "/license": license,
    "/license.html": license,
  },
  fetch: () => new Response("Not found", { status: 404 }),
});
