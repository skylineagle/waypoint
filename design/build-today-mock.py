head = open('onboarding-trek.html').read().split('<body>')[0]
extra = '''<style>
.phone.tall{height:780px}
.scroll{position:absolute;top:48px;left:0;right:0;bottom:0;overflow:hidden;padding:0 16px}
.tabbar{position:absolute;left:50%;transform:translateX(-50%);bottom:22px;display:flex;gap:4px;padding:5px;border-radius:999px;background:rgba(255,255,255,.72);backdrop-filter:blur(18px);border:1px solid rgba(0,0,0,.06);box-shadow:0 8px 24px rgba(0,0,0,.12);z-index:8}
.tabbar span{display:flex;flex-direction:column;align-items:center;font-size:10px;font-weight:600;color:var(--muted);padding:6px 18px;border-radius:999px;gap:2px}.tabbar span.on{background:rgba(17,24,39,.08);color:var(--ink)}.tabbar svg.lucide{width:19px;height:19px}
.hdr{display:flex;justify-content:space-between;align-items:flex-start;padding:6px 2px 10px}
.hdr .e{font-size:11px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;color:var(--faint)}
.hdr .t{font-size:24px;font-weight:700;letter-spacing:-.02em;line-height:1.15}
.wx{display:inline-flex;gap:5px;align-items:center;background:#fff;border:1px solid var(--border);border-radius:999px;padding:5px 10px;font-size:12px;font-weight:600}.wx svg.lucide{width:14px;height:14px;color:#f59e0b}
.next{background:#15151A;color:#F5F5F7;border-radius:20px;padding:15px}
.next .cap{font-size:10px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;color:rgba(245,245,247,.55)}
.next .n{font-size:21px;font-weight:700;margin-top:3px;letter-spacing:-.01em}
.next .a{font-size:12px;color:rgba(245,245,247,.6);margin-top:2px}
.next .meta{display:flex;gap:12px;font-size:11.5px;color:rgba(245,245,247,.8);margin-top:10px}.next .meta span{display:flex;gap:5px;align-items:center}.next .meta svg.lucide{width:13px;height:13px}
.next .acts{display:flex;gap:8px;margin-top:12px}
.gbtn{flex:1;height:40px;border-radius:999px;display:flex;align-items:center;justify-content:center;gap:6px;font-size:13px;font-weight:600}
.gbtn.l{background:#F5F5F7;color:#09090b}.gbtn.d{background:rgba(255,255,255,.12);color:#fff;border:1px solid rgba(255,255,255,.14)}.gbtn svg.lucide{width:15px;height:15px}
.prog{display:flex;gap:4px;margin-top:12px}.prog i{flex:1;height:4px;border-radius:2px;background:rgba(255,255,255,.18)}.prog i.on{background:#4ADE80}
.sec{font-size:10px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;color:var(--faint);margin:16px 2px 8px;display:flex;justify-content:space-between}
.tl{position:relative}
.stop{display:flex;gap:10px;align-items:flex-start;padding:8px 0;position:relative}
.stop .dot{width:26px;height:26px;border-radius:50%;flex:none;display:grid;place-items:center;font-size:11px;font-weight:700;background:#fff;border:1.5px solid var(--border);color:var(--muted);z-index:2}
.stop.done .dot{background:var(--success);border-color:var(--success);color:#fff}.stop.now .dot{background:var(--ink);border-color:var(--ink);color:#fff}
.stop .b{flex:1;background:#fff;border:1px solid var(--border);border-radius:14px;padding:9px 11px}
.stop.done .b{opacity:.55}.stop.now .b{border-color:var(--ink);box-shadow:0 0 0 1px var(--ink)}
.stop .b .n{font-size:13.5px;font-weight:600}.stop .b .m{font-size:11px;color:var(--muted);margin-top:1px}
.stop .b .tag{display:inline-block;font-size:10.5px;font-weight:600;padding:2px 7px;border-radius:999px;margin-top:5px}
.tl::before{content:"";position:absolute;left:12.5px;top:18px;bottom:18px;width:1.5px;background:var(--border)}
.leg{font-size:10.5px;color:var(--faint);padding:0 0 0 36px;display:flex;gap:5px;align-items:center}.leg svg.lucide{width:12px;height:12px}
.res{border-left:3px solid #9333ea}
.row2{display:flex;gap:8px}
.mini{flex:1;background:#fff;border:1px solid var(--border);border-radius:16px;padding:11px 12px}
.mini .c{font-size:10px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;color:var(--faint)}
.mini .v{font-size:15px;font-weight:700;margin-top:3px}.mini .s{font-size:11px;color:var(--muted)}
.map{height:250px;margin:0 -16px;background:linear-gradient(135deg,#dbe7d5 0%,#e8efe4 40%,#cfe0ea 100%);position:relative;overflow:hidden}
.map::before{content:"";position:absolute;inset:0;background-image:linear-gradient(90deg,rgba(255,255,255,.7) 2px,transparent 2px),linear-gradient(rgba(255,255,255,.7) 2px,transparent 2px);background-size:46px 46px,46px 46px;transform:rotate(12deg) scale(1.4)}
.pin{position:absolute;width:24px;height:24px;border-radius:50%;background:var(--ink);color:#fff;font-size:11px;font-weight:700;display:grid;place-items:center;border:2px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,.25);z-index:2}.pin.done{background:var(--success)}
.route{position:absolute;inset:0;z-index:1}
.sheetc{background:var(--bg);border-radius:22px 22px 0 0;margin:-22px -16px 0;padding:10px 16px 0;position:relative;z-index:3}
.grab{width:36px;height:5px;border-radius:3px;background:#d1d5db;margin:0 auto 10px}
.hero{color:#F5F5F7;border-radius:20px;padding:16px;background:linear-gradient(135deg,#1c1c24,#15151A)}
.lock{background:linear-gradient(160deg,#2b3a67 0%,#1b2340 45%,#0b1020 100%);color:#fff}
.lock .status{color:#fff}
.clock{text-align:center;margin-top:40px}.clock .d{font-size:14px;font-weight:600;opacity:.85}.clock .h{font-size:78px;font-weight:700;letter-spacing:-2px;line-height:1}
.la{margin:28px 10px 0;background:rgba(20,20,26,.72);backdrop-filter:blur(20px);border-radius:24px;padding:14px;color:#fff;border:1px solid rgba(255,255,255,.08)}
.la .top{display:flex;align-items:center;gap:8px;font-size:11px;color:rgba(255,255,255,.6);font-weight:600}.la .top img{height:14px}
.la .row{display:flex;justify-content:space-between;align-items:flex-end;margin-top:6px}
.la .n{font-size:19px;font-weight:700}.la .sub{font-size:12px;color:rgba(255,255,255,.65)}
.la .amt{text-align:right}.la .amt b{font-size:17px;display:block}.la .amt small{font-size:10.5px;color:rgba(255,255,255,.55)}
.di{margin:14px auto 0;width:210px;height:36px;border-radius:20px;background:#000;display:flex;align-items:center;justify-content:space-between;padding:0 12px;color:#fff;font-size:12px;font-weight:700}
.di .l{display:flex;gap:6px;align-items:center}.di .dotn{width:20px;height:20px;border-radius:50%;background:#4ADE80;color:#000;display:grid;place-items:center;font-size:10px}
.die{margin:14px 8px 0;border-radius:36px;background:#000;color:#fff;padding:14px 16px}
.die .r{display:flex;justify-content:space-between;align-items:center}.die .n{font-size:16px;font-weight:700}.die .s{font-size:11.5px;color:rgba(255,255,255,.6)}
.die .b{display:flex;gap:8px;margin-top:10px}.die .b span{flex:1;height:34px;border-radius:999px;background:rgba(255,255,255,.14);display:flex;align-items:center;justify-content:center;gap:5px;font-size:12px;font-weight:600}.die .b svg.lucide{width:14px;height:14px}
.hs{background:linear-gradient(160deg,#dfe7ff,#f6e8ff 60%,#ffe9dd)}
.wgrid{display:grid;grid-template-columns:1fr 1fr;gap:16px;padding:40px 22px 0}
.wsm{aspect-ratio:1;border-radius:22px;background:#15151A;color:#fff;padding:13px;display:flex;flex-direction:column;justify-content:space-between}
.wsm .c{font-size:10px;font-weight:700;letter-spacing:.08em;color:rgba(255,255,255,.55);text-transform:uppercase}.wsm .n{font-size:15px;font-weight:700;line-height:1.15}.wsm .s{font-size:11px;color:rgba(255,255,255,.6)}
.wmd{grid-column:span 2;height:150px;border-radius:22px;background:#fff;padding:14px;display:flex;gap:12px}
.wmd .l{flex:1;display:flex;flex-direction:column;justify-content:space-between}.wmd .r{width:120px;border-left:1px solid var(--border);padding-left:12px;display:flex;flex-direction:column;justify-content:space-between}
.wmd .c{font-size:10px;font-weight:700;letter-spacing:.08em;color:var(--faint);text-transform:uppercase}.wmd .n{font-size:16px;font-weight:700}.wmd .s{font-size:11.5px;color:var(--muted)}
.wadd{height:32px;border-radius:999px;background:var(--ink);color:#fff;display:flex;align-items:center;justify-content:center;gap:5px;font-size:12px;font-weight:600}.wadd svg.lucide{width:14px;height:14px}
.appicon{width:58px;height:58px;border-radius:14px;background:rgba(255,255,255,.6)}
.count{font-family:MuseoModerno,sans-serif;font-size:48px;font-weight:700;line-height:1;letter-spacing:-.02em}
</style>'''

status = '<div class="status"><span>9:41</span><span>●●● ▮</span></div>'
tabbar = '<div class="tabbar"><span class="on"><i data-lucide="sun"></i>Today</span><span><i data-lucide="wallet"></i>Costs</span></div>'


def phone(inner, caption, extra_class="", with_tabs=True):
    tabs = tabbar if with_tabs else ""
    return f'<div><div class="phone tall {extra_class}"><div class="island"></div>{status}<div class="scroll">{inner}</div>{tabs}<div class="home"></div></div><div class="caption">{caption}</div></div>'


def stop(number, name, meta, state="", tag=""):
    mark = "✓" if state == "done" else number
    return f'<div class="stop {state}"><div class="dot">{mark}</div><div class="b"><div class="n">{name}</div><div class="m">{meta}</div>{tag}</div></div>'


def leg(text):
    return f'<div class="leg"><i data-lucide="footprints"></i>{text}</div>'


header = '<div class="hdr"><div><div class="e">Day 3 of 20 · Wed 7 Oct</div><div class="t">Asakusa &amp; Ueno</div></div><span class="wx"><i data-lucide="sun"></i>22°</span></div>'
next_card = '<div class="next"><div class="cap">Up next · 2 of 5</div><div class="n">Nakamise Shopping Street</div><div class="a">1-chōme-36-3 Asakusa, Taito City</div><div class="meta"><span><i data-lucide="footprints"></i>6 min walk</span><span><i data-lucide="map-pin"></i>0.4 km</span></div><div class="acts"><span class="gbtn l"><i data-lucide="navigation"></i>Directions</span><span class="gbtn d"><i data-lucide="check"></i>Done</span></div><div class="prog"><i class="on"></i><i></i><i></i><i></i><i></i></div></div>'
timeline = ('<div class="sec"><span>Today\'s plan</span><span>5 stops</span></div><div class="tl">'
            + stop(1, "Sensō-ji", "2-chōme-3-1 Asakusa", "done") + leg("6 min walk")
            + stop(2, "Nakamise Shopping Street", "Shopping street", "now") + leg("4 min walk")
            + stop(3, "Asakusa Gyukatsu", "Restaurant", "", '<span class="tag" style="background:#fff1e6;color:#ea580c">Food</span>') + leg("18 min by train")
            + stop(4, "Ueno Park", "Park") + leg("9 min walk")
            + stop(5, "Ameyoko market", "Market") + '</div>')
tonight = '<div class="sec"><span>Tonight</span></div><div class="mini"><div class="c">Hotel · night 2 of 4</div><div class="v">the square hotel GINZA</div><div class="s">2-chōme-11-6 Ginza · 25 min by train</div></div>'
spend = '<div class="row2" style="margin-top:8px"><div class="mini"><div class="c">Spent today</div><div class="v">₪212</div><div class="s">≈ ¥11,050 · avg ₪416</div></div><div class="mini" style="display:flex;align-items:center;justify-content:center;gap:6px;font-weight:600;font-size:13px"><i data-lucide="plus"></i>Add expense</div></div>'

a1 = phone(header + next_card + timeline, "A · Up-next card + timeline")
a2 = phone('<div style="margin-top:-150px"></div>' + timeline + tonight + spend, "A · scrolled: tonight's hotel + today's spend")
map_view = ('<div class="map"><svg class="route" viewBox="0 0 320 250"><path d="M60 60 C 120 80, 130 120, 170 130 S 250 170, 270 210" stroke="#111827" stroke-width="3" fill="none" stroke-dasharray="6 5"/></svg>'
            '<div class="pin done" style="left:48px;top:48px">✓</div><div class="pin" style="left:120px;top:92px;box-shadow:0 0 0 6px rgba(17,24,39,.15)">2</div>'
            '<div class="pin" style="left:160px;top:120px">3</div><div class="pin" style="left:230px;top:165px">4</div><div class="pin" style="left:260px;top:200px">5</div></div>')
b1 = phone(map_view + '<div class="sheetc"><div class="grab"></div>' + header + '<div class="next" style="padding:12px 14px"><div class="cap">Up next · 6 min walk</div><div class="n" style="font-size:18px">Nakamise Shopping Street</div><div class="acts" style="margin-top:10px"><span class="gbtn l"><i data-lucide="navigation"></i>Directions</span><span class="gbtn d"><i data-lucide="check"></i>Done</span></div></div></div>', "B · Map-first, plan in a sheet")

before_trip = ('<div class="hdr"><div><div class="e">Your next trip</div><div class="t">Japan</div></div><span class="wx"><i data-lucide="calendar"></i>5 – 24 Oct</span></div>'
               '<div class="hero"><div style="font-size:10px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;color:rgba(245,245,247,.55)">Starts in</div><div class="count">9 days</div><div style="font-size:12px;color:rgba(245,245,247,.62);margin-top:6px">20 days · 3 hotels · 10 bookings</div></div>'
               '<div class="sec"><span>Day 1 · Mon 5 Oct</span></div><div class="stop now" style="padding-top:0"><div class="dot"><i data-lucide="plane" style="width:13px;height:13px"></i></div><div class="b res"><div class="n">EL AL LY75 · Tel Aviv → Tokyo</div><div class="m">Departs 22:45 · booking details in TREK</div></div></div>'
               '<div class="sec"><span>First nights</span></div><div class="mini"><div class="c">Hotel · 6 – 10 Oct</div><div class="v">the square hotel GINZA</div><div class="s">Ginza, Chuo City</div></div>'
               '<div class="mini" style="margin-top:8px;display:flex;align-items:center;gap:10px"><i data-lucide="bell" style="width:18px;height:18px"></i><div><div style="font-size:13px;font-weight:600">Live Activity starts on day 1</div><div style="font-size:11px;color:var(--muted)">Your next stop on the Lock Screen</div></div></div>')
pre = phone(before_trip, "Before the trip (now)")

lock_inner = ('<div class="clock"><div class="d">Wednesday 7 October</div><div class="h">10:24</div></div>'
              '<div class="la"><div class="top"><img src="logo-light.svg"> Japan · Day 3 · Asakusa &amp; Ueno</div><div class="row"><div><div class="sub">Up next · 6 min walk</div><div class="n">Nakamise Street</div></div><div class="amt"><b>₪212</b><small>today</small></div></div><div class="prog"><i class="on"></i><i></i><i></i><i></i><i></i></div></div>'
              '<div class="di"><span class="l"><span class="dotn">2</span>Nakamise</span><span>₪212</span></div>'
              '<div class="die"><div class="r"><div><div class="s">Up next · 2 of 5</div><div class="n">Nakamise Street</div></div><div style="text-align:right"><div class="s">today</div><div class="n">₪212</div></div></div><div class="b"><span><i data-lucide="navigation"></i>Go</span><span><i data-lucide="check"></i>Done</span><span><i data-lucide="plus"></i>Expense</span></div></div>')
lock = f'<div><div class="phone tall lock"><div class="island"></div>{status}{lock_inner}<div class="home" style="background:#fff"></div></div><div class="caption">Live Activity · Lock Screen, Dynamic Island compact + expanded</div></div>'

widget_inner = ('<div class="wgrid"><div class="wsm"><div class="c">Up next · 2/5</div><div><div class="n">Nakamise Street</div><div class="s">6 min walk</div></div></div>'
                '<div class="wsm" style="background:#fff;color:var(--ink)"><div class="c" style="color:var(--faint)">Today</div><div><div class="n" style="font-size:24px">₪212</div><div class="s" style="color:var(--muted)">avg ₪416/day</div></div></div>'
                '<div class="wmd"><div class="l"><div><div class="c">Day 3 · Asakusa &amp; Ueno</div><div class="n" style="margin-top:4px">Nakamise Street</div><div class="s">Up next · 6 min walk</div></div><div class="prog"><i class="on" style="background:var(--success)"></i><i style="background:var(--border)"></i><i style="background:var(--border)"></i><i style="background:var(--border)"></i><i style="background:var(--border)"></i></div></div>'
                '<div class="r"><div><div class="c">Spent today</div><div class="n">₪212</div></div><div class="wadd"><i data-lucide="plus"></i>Expense</div></div></div>'
                '<div class="appicon"></div><div class="appicon"></div></div>')
widgets = f'<div><div class="phone tall hs"><div class="island"></div>{status}{widget_inner}<div class="home"></div></div><div class="caption">Home Screen widgets · small ×2, medium with quick add</div></div>'

html = head.replace('</head>', extra + '</head>') + f'''<body><h1 class="page">Today · Trek Companion</h1>
<p class="lead">Built from TREK's real data for your Japan trip. Days have ordered stops with no times, so <b>Done</b> moves "Up next" along (stored on the phone). Bookings with times (flight, tickets, dinner) are shown too, along with hotels by night. Walking and transit times are computed on the device with Apple Maps, and <b>Directions</b> opens Apple Maps.<br>
<b>UX (AppLlama):</b> Wanderlog's itinerary (numbered stop cards with the travel time between stops) and Tripsy's clean trip overview. <b>Look:</b> TREK tokens plus a native Liquid Glass tab bar (Today | Costs).</p>
<h2 style="margin:6px 0 14px;font-size:18px">During the trip: pick a layout</h2><div class="row">{a1}{a2}{b1}</div>
<h2 style="margin:40px 0 14px;font-size:18px">Shared: before the trip, Live Activity, widgets</h2><div class="row">{pre}{lock}{widgets}</div>
<script>lucide.createIcons();</script></body></html>'''
open('today-variants.html', 'w').write(html)
