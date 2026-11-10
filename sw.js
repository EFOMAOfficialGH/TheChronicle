/* The Chronicle service worker: keeps the app shell available offline and picks up new versions quickly. */
const V='chronicle-v5';
const SHELL=['./','./index.html','./manifest.webmanifest','./icons/icon-192.png','./icons/icon-512.png'];
const SDK='https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.57.4/dist/umd/supabase.js';
self.addEventListener('install',e=>{e.waitUntil(caches.open(V).then(async c=>{await c.addAll(SHELL);try{const r=await fetch(SDK);if(r.ok)await c.put(SDK,r);}catch(x){/* offline boot does not require the SDK */}}).then(()=>self.skipWaiting()));});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==V).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));});
self.addEventListener('fetch',e=>{
  const r=e.request,u=new URL(r.url);
  if(r.method!=='GET'||u.hostname.endsWith('supabase.co'))return;            /* never touch live data */
  const page=r.mode==='navigate'||u.pathname.endsWith('.html')||u.pathname.endsWith('/');
  if(page){                                                                   /* network first, so a new commit shows up fast */
    e.respondWith(fetch(r).then(res=>{const cp=res.clone();caches.open(V).then(c=>c.put(r,cp));return res;}).catch(()=>caches.match(r).then(m=>m||caches.match('./index.html'))));
    return;
  }
  e.respondWith(caches.match(r).then(m=>{                                      /* everything else: cached copy now, refresh behind */
    const net=fetch(r).then(res=>{if(res&&(res.ok||res.type==='opaque')){const cp=res.clone();caches.open(V).then(c=>c.put(r,cp));}return res;}).catch(()=>m);
    return m||net;
  }));
});
