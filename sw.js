/* E-Wallet all-in-one — service worker (offline + online) */
const CACHE = 'ewallet-supabase-v2';
const CORE  = ['./', './index.html'];

self.addEventListener('install', e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(CORE).catch(()=>{})));
});

self.addEventListener('activate', e => {
  e.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;                  // POST (Gist/EmailJS) -> rete
  const isNav = req.mode === 'navigate' || req.destination === 'document';

  if (isNav) {
    // network-first: online sempre aggiornato, offline dalla cache
    e.respondWith((async () => {
      try {
        const fresh = await fetch(req);
        const c = await caches.open(CACHE);
        c.put('./index.html', fresh.clone()).catch(()=>{});
        return fresh;
      } catch (_) {
        return (await caches.match(req)) || (await caches.match('./index.html')) || (await caches.match('./'));
      }
    })());
  } else {
    // cache-first per font e altre risorse statiche
    e.respondWith((async () => {
      const cached = await caches.match(req);
      if (cached) return cached;
      try {
        const fresh = await fetch(req);
        const c = await caches.open(CACHE);
        c.put(req, fresh.clone()).catch(()=>{});
        return fresh;
      } catch (_) {
        return cached || Response.error();
      }
    })());
  }
});
