"""Partner-card / crest UI mockup. usage: crest_mockup.py VECTOR_DIR  -> VECTOR_DIR/crest-mockup.html"""
import json, os, sys
V = sys.argv[1]
man = [e for e in json.load(open(os.path.join(V, "manifest.json"))) if not e["stage"].startswith("x")]
crests = json.load(open(os.path.join(V, "crests", "crests.json")))
data = {"man": [{k: e[k] for k in ("line", "stage", "name", "png", "native")} for e in man], "crests": crests}
HTML = r"""<!doctype html><html lang="ko"><head><meta charset="utf-8"><title>문장 UI 목업</title>
<style>
:root{--bg:#f3f2ee;--card:#fff;--ink:#222;--mute:#8a8a8a;--line:#e4e2dc;--orange:#ff8a00}
*{box-sizing:border-box}body{margin:0;background:var(--bg);font:13px -apple-system,BlinkMacSystemFont,"Apple SD Gothic Neo",sans-serif;color:var(--ink)}
img.px{image-rendering:pixelated}
header{padding:14px 20px;border-bottom:1px solid var(--line);background:#fff;display:flex;gap:18px;align-items:center;flex-wrap:wrap}
header h1{font-size:15px;margin:0 8px 0 0}
.seg{display:flex;gap:4px}.seg button{border:1px solid var(--line);background:#fff;border-radius:8px;padding:5px 9px;cursor:pointer;font:inherit;display:flex;gap:5px;align-items:center}
.seg button.on{border-color:#333;background:#333;color:#fff}
.act button{border:0;background:#2d6cdf;color:#fff;border-radius:8px;padding:6px 11px;cursor:pointer;font:inherit}.act button:disabled{background:#c9c9c9;cursor:default}
main{display:grid;grid-template-columns:360px 1fr;gap:24px;padding:20px;max-width:1150px}
h2{font-size:12px;color:var(--mute);font-weight:600;margin:0 0 8px;letter-spacing:.02em}
/* menu bar */
.menubar{height:24px;background:#e9e9ec;border:1px solid #d0d0d4;border-radius:6px;display:flex;align-items:center;justify-content:flex-end;gap:10px;padding:0 10px;font-size:12px;margin-bottom:18px}
.mbitem{position:relative;height:22px;display:flex;align-items:flex-end;gap:5px}
.mbitem .spr{height:22px;display:flex;align-items:flex-end}
.badge{position:absolute;top:-1px;width:6px;height:13px}
.badge.ready{animation:bob .6s steps(2) infinite}
@keyframes bob{50%{transform:translateY(-2px)}}
.mbcrest{position:absolute;top:0;width:20px;height:20px;opacity:0;pointer-events:none}
.mbcrest.go{animation:twinkle 1.6s ease-out}
@keyframes twinkle{0%{opacity:0;transform:scale(.4)}20%{opacity:1;transform:scale(1.2)}40%{transform:scale(1)}60%{opacity:1}100%{opacity:0}}
/* popover card */
.pop{background:var(--card);border-radius:14px;box-shadow:0 8px 30px rgba(0,0,0,.12);padding:16px;position:relative;overflow:hidden}
.stage{height:150px;display:flex;align-items:flex-end;justify-content:center;background:linear-gradient(#fbfaf6,#f0eee6);border-radius:10px;position:relative}
.stage img{margin-bottom:10px}
.stage .bigbadge{position:absolute}
.nm{display:flex;justify-content:space-between;align-items:baseline;margin:12px 0 6px}.nm b{font-size:15px}.nm span{color:var(--mute)}
.bar{height:8px;border-radius:4px;background:#eee;overflow:hidden}.bar i{display:block;height:100%;background:#57b46a;border-radius:4px;transition:width .6s}
.row{display:flex;align-items:center;gap:10px;margin-top:14px;padding:10px;border:1px solid var(--line);border-radius:10px;position:relative}
.row .ic{width:52px;min-height:56px;display:flex;align-items:center;justify-content:center;flex:none}
.row .t{flex:1;min-width:0}.row .t b{display:block;font-size:13px}.row .t small{color:var(--mute)}
.row .bar{margin-top:5px;height:6px}.row .bar i{background:#bbb}
.off{filter:grayscale(1) brightness(1.1) opacity(.45)}
.glow{animation:glow 2.4s ease-in-out infinite}
@keyframes glow{50%{filter:drop-shadow(0 0 4px var(--cc)) brightness(1.15)}}
.chip{font-size:11px;padding:2px 7px;border-radius:9px;background:#f3f3f3;color:#666;white-space:nowrap}
.chip.lit{background:var(--cc);color:#fff}
.hint{margin-top:8px;font-size:12px;color:#555;background:#f7f6f2;border-radius:8px;padding:7px 9px}
.hint a{color:#2d6cdf;cursor:pointer;text-decoration:underline}
.tip{position:absolute;right:12px;top:12px;background:#222;color:#fff;border-radius:8px;padding:8px 10px;font-size:12px;line-height:1.6;display:none;z-index:5;min-width:160px}
.tip .ok{color:#7ddc8a}.tip .no{color:#ff8e8e}
.badgeHit{position:absolute;cursor:help}
.badgeHit:hover+.tip,.tip:hover{display:block}
/* overlay events */
.ov{position:absolute;inset:0;background:rgba(20,20,30,.82);display:flex;flex-direction:column;align-items:center;justify-content:center;color:#fff;opacity:0;pointer-events:none;transition:opacity .3s;z-index:10}
.ov.show{opacity:1;pointer-events:auto}
.ov img{width:96px;height:96px;filter:drop-shadow(0 0 14px var(--cc))}
.ov.show img{animation:rise 1.2s cubic-bezier(.2,1.4,.4,1)}
@keyframes rise{0%{transform:scale(.2) translateY(30px);opacity:0}100%{transform:none;opacity:1}}
.ov p{font-size:16px;font-weight:700;margin:16px 0 4px}.ov small{opacity:.7}
.fly{position:absolute;z-index:11;transition:all .9s cubic-bezier(.5,0,.3,1);image-rendering:pixelated}
/* notebook */
.nb{background:#fff;border-radius:12px;padding:12px 14px}
.nbrow{display:flex;align-items:center;gap:10px;padding:7px 0;border-bottom:1px solid #f0efea}
.nbrow:last-child{border:0}
.nbrow .em{width:32px;display:flex;justify-content:center}
.nbrow .lbl{width:44px;font-weight:600}
.nbrow .cells{display:flex;gap:6px;flex:1}
.cell{width:52px;height:46px;border-radius:7px;background:#f7f6f2;display:flex;align-items:flex-end;justify-content:center;padding-bottom:3px;position:relative}
.cell img{max-width:46px;max-height:40px}
.cell.unk img{filter:brightness(0) opacity(.18)}
.cell.cur{outline:2px solid #2d6cdf}
.gal{display:flex;gap:18px;flex-wrap:wrap;background:#fff;border-radius:12px;padding:14px;color:#555}
.gal div{display:flex;flex-direction:column;align-items:center;gap:6px;font-size:11px}
.checks{display:flex;gap:6px;flex-wrap:wrap;margin-top:7px;font-size:11px}.checks span{padding:2px 7px;border-radius:9px;background:#f3f3f3;color:#888}.checks span:first-child{background:none;padding-left:0;color:#555;font-weight:600}.checks .ok{background:#e6f5e9;color:#2f8a44}
.dvon{filter:drop-shadow(0 0 3px #7fc8ff)}.dvbuy{animation:dvbuy .9s cubic-bezier(.2,1.6,.4,1)}@keyframes dvbuy{0%{transform:scale(.3) rotate(-20deg);opacity:0}100%{transform:none;opacity:1}}
.note{color:var(--mute);font-size:12px;line-height:1.6;margin-top:10px}
</style></head><body>
<header><h1>문장 UI 목업</h1>
 <div class="seg" id="lines"></div>
</header>
<header>
 <div class="seg" id="states"></div>
 <div class="act"><button id="aDv">상점: 디지바이스 구매</button> <button id="aEvo1">성숙기로 진화</button> <button id="aTag">상점: 펜던트 구매</button> <button id="aAch">업적 달성 ▶ 문장 빛남</button> <button id="aEvo">완전체로 진화</button></div>
</header>
<main>
 <section>
  <h2>메뉴바</h2>
  <div class="menubar"><span>🔋</span><div class="mbitem" id="mb"></div><span id="mbtxt">200.7M · 82%</span><span>14:20</span></div>
  <h2>팝오버 · 파트너 카드</h2>
  <div class="pop" id="pop"></div>
  <p class="note">"!"는 진화할 수 있을 때만 나타납니다. 조건은 카드의 게이지 아래에 항상 보입니다.<br>위 버튼으로 상태를 넘기면 빛남 연출과 펜던트 장착 연출이 재생됩니다.</p>
 </section>
 <section>
  <h2>수첩 (계열별 · 문장 엠블럼)</h2>
  <div class="nb" id="nb"></div>
  <h2 style="margin-top:20px">아이템 · 문장 (공식 V-Pet 문장 도트 24×24 · 펜던트 · 디지바이스 · 고기)</h2>
  <div class="gal" id="gal"></div>
 </section>
</main>
<script>
const DATA=__DATA__;
const LINES=['agumon','gabumon','biyomon','tentomon','palmon','gomamon','patamon','tailmon'];
const LKO={agumon:'아구몬',gabumon:'파피몬',biyomon:'피요몬',tentomon:'텐타몬',palmon:'팔몬',gomamon:'쉬라몬',patamon:'파닥몬',tailmon:'가트몬'};
const STK=['유년기 I','유년기 II','성장기','성숙기','완전체','궁극체'];
const STATES=[['r_no','① 디지바이스 없음'],['r_has','② 디지바이스 · 진화 가능'],['nop','③ 펜던트 없음'],['off','④ 문장 꺼짐'],['lit','⑤ 문장 빛남 · 진화 가능'],['ult','⑥ 완전체']];
const sp=(l,i)=>DATA.man.find(e=>e.line===l&&e.stage[0]===String(i));
let line='agumon',state='r_no';
const EXCL=c=>`<svg viewBox="0 0 4 9" shape-rendering="crispEdges"><path fill="${c}" d="M1 0h2v1h1v3h-1v1h-2v-1h-1v-3h1z M1 6h2v1h1v1h-1v1h-2v-1h-1v-1h1z"/><path fill="#5a2c00" opacity=".55" d="M0 1h1v3h-1zM0 7h1v1h-1z"/></svg>`;
function px(src,n,s,cls=''){return `<img class="px ${cls}" src="${src}" width="${n[0]*s}" height="${n[1]*s}">`;}
function crest(l){return `crests/${l}.png`;}
const CR=[24,24],TG=[40,68],DV=[40,38];
function view(){
 const c=DATA.crests[line];document.documentElement.style.setProperty('--cc',c.color);
 const rookie=state.startsWith('r_'), stageIdx=rookie?2:state==='ult'?4:3, e=sp(line,stageIdx);
 const ready=state==='lit'||state==='r_has';                       // the "!" shows only when evolution is possible
 const has=state!=='nop', lit=state==='lit'||state==='ult';
 const checks=rookie?[[true,'진화 게이지 100%'],[state==='r_has','디지바이스']]:stageIdx===3
  ?[[true,'진화 게이지 100%'],[has,'펜던트'],[lit,`${c.ko}의 문장`+(lit?'':' (57%)')]]
  :[[false,'진화 게이지 64%'],[false,'유대 Lv 3 / 5']];
 const next=['','','성숙기','완전체','궁극체'][stageIdx];
 // menu bar
 const [w,h]=e.native, s=h<=22?1:22/h;
 document.getElementById('mb').innerHTML=`<div class="spr">${px(e.png,[w,h],s)}</div>
   ${ready?`<div class="badge ready" style="left:${Math.round(w*s)+1}px">${EXCL('#ff8a00')}</div>`:''}
   <img class="px mbcrest" id="mbcrest" src="${crest(line)}" style="left:${Math.round(w*s)+2}px">`;
 document.getElementById('mb').querySelector('.spr img').style.imageRendering=h>22?'auto':'pixelated';
 // card: one row = pendant + crest
 const sc=Math.min(3,Math.floor(120/Math.max(h,w*0.8)))||1, sw=w*sc, shh=h*sc;
 const prog=`<small>${c.ko}의 시련 · 성숙기로 7일 함께하기 4/7</small><div class="bar"><i style="width:57%"></i></div>`;
 let row;
 if(state==='r_no')row=`<div class="ic">${px('items/digivice.png',DV,1,'off')}</div>
   <div class="t"><b>디지바이스</b><small>성숙기 진화에 필요해요 · 파트너마다 1개</small></div><span class="chip">필요</span>`;
 else if(state==='r_has')row=`<div class="ic">${px('items/digivice.png',DV,1,'dvon')}</div>
   <div class="t"><b>디지바이스</b><small>파트너와 연결됐어요</small></div><span class="chip lit">보유</span>`;
 else if(state==='nop')row=`<div class="ic">${px('items/pendant.png',TG,1,'off')}</div>
   <div class="t"><b>${c.ko}의 문장</b><small>펜던트가 있어야 문장을 끼울 수 있어요</small></div><span class="chip">펜던트 필요</span>`;
 else if(state==='off')row=`<div class="ic">${px('items/pendant_'+line+'_off.png',TG,1)}</div>
   <div class="t"><b>펜던트 · ${c.ko}의 문장</b>${prog}</div><span class="chip">꺼짐</span>`;
 else if(state==='lit')row=`<div class="ic">${px('items/pendant_'+line+'.png',TG,1,'glow')}</div>
   <div class="t"><b>펜던트 · ${c.ko}의 문장</b><small>문장이 빛나고 있어요</small></div><span class="chip lit">빛남</span>`;
 else row=`<div class="ic">${px('items/pendant_'+line+'.png',TG,1,'glow')}</div>
   <div class="t"><b>펜던트 · ${c.ko}의 문장</b><small>궁극체까지 유대 Lv 3 / 5 · 고기를 주면 유대가 올라요</small><div class="bar"><i style="width:60%;background:var(--cc)"></i></div></div><span class="chip lit">빛남</span>`;
 const hint=state==='r_no'?`<div class="hint">성숙기로 가려면 디지바이스가 필요해요 → <a onclick="doDv()">상점</a></div>`
   :state==='r_has'?`<div class="hint">성숙기로 진화할 수 있어요! 메뉴바의 <b style="color:var(--orange)">!</b>를 눌러 진화시키세요.</div>`
   :state==='nop'?`<div class="hint">완전체로 가려면 펜던트가 필요해요 → <a onclick="doTag()">상점</a></div>`
   :state==='off'?`<div class="hint">펜던트에 문장을 끼웠어요. ${c.ko}의 시련을 마치면 문장이 빛나요.</div>`
   :state==='lit'?`<div class="hint">완전체로 진화할 수 있어요! 메뉴바의 <b style="color:var(--orange)">!</b>를 눌러 진화시키세요.</div>`:'';
 document.getElementById('pop').innerHTML=`
  <div class="stage">${px(e.png,[w,h],sc)}
   ${ready?`<div class="bigbadge" style="left:calc(50% + ${sw/2+4}px);bottom:${10+shh-8}px;width:12px;height:27px">${EXCL('#ff8a00')}</div>`:''}
  </div>
  <div class="nm"><b>${e.name}</b><span>${LKO[line]} 계열 · ${STK[stageIdx]}</span></div>
  <div class="bar"><i style="width:${stageIdx<4?100:64}%"></i></div>
  <div class="checks"><span>${next}까지</span>${checks.map(([ok,t])=>`<span class="${ok?'ok':'no'}">${ok?'✓':'·'} ${t}</span>`).join('')}</div>
  <div class="row" id="crow">${row}</div>${hint}
  <div class="ov" id="ov"><img class="px" src="${crest(line)}"><p>${c.ko}의 문장이 빛났다!</p><small>완전체 진화가 열렸어요</small></div>`;
 if(ready)document.querySelector('.bigbadge').style.animation='bob .6s steps(2) infinite';
 document.getElementById('aDv').disabled=state!=='r_no';document.getElementById('aEvo1').disabled=state!=='r_has';document.getElementById('aTag').disabled=state!=='nop';document.getElementById('aAch').disabled=state!=='off';document.getElementById('aEvo').disabled=state!=='lit';
 document.querySelectorAll('#states button').forEach(b=>b.classList.toggle('on',b.dataset.k===state));
 document.querySelectorAll('#lines button').forEach(b=>b.classList.toggle('on',b.dataset.k===line));
 notebook();
}
function notebook(){
 const reached=state.startsWith('r_')?2:state==='ult'?4:3;
 document.getElementById('nb').innerHTML=LINES.map(l=>{
  const c=DATA.crests[l], mine=l===line, litC=mine&&(state==='lit'||state==='ult');
  const upto=mine?reached:(l==='gabumon'?2:-1);  // pretend gabumon was raised to rookie before
  const cells=[0,1,2,3,4,5].map(i=>{const e=sp(l,i);const known=i<=upto;
    return `<div class="cell ${known?'':'unk'} ${mine&&i===reached?'cur':''}" title="${known?e.name:'???'}"><img class="px" src="${e.png}" style="image-rendering:${e.native[1]>40?'auto':'pixelated'}"></div>`}).join('');
  return `<div class="nbrow"><div class="em">${px(crest(l),CR,1,litC?'':'off')}</div><div class="lbl" style="color:${litC?c.color:'#999'}">${c.ko}</div><div class="cells">${cells}</div></div>`;}).join('');
}
function gallery(){
 document.getElementById('gal').innerHTML=LINES.map(l=>`<div>${px(crest(l),CR,3)}<div style="display:flex;gap:6px;align-items:flex-end">${px('items/pendant_'+l+'.png',TG,1)}${px(crest(l),CR,1,'off')}</div>${DATA.crests[l].ko}</div>`).join('')+`<div>${px('items/pendant.png',TG,2)}빈 펜던트 (상점)</div><div>${px('items/digivice.png',DV,2)}디지바이스 (상점)</div><div>${px('items/meat.png',[16,16],3)}고기 (상점)</div>`;
}
function doAch(){ if(state!=='off')return; state='lit';view();
 const ov=document.getElementById('ov');ov.classList.add('show');setTimeout(()=>ov.classList.remove('show'),2200);
 const m=document.getElementById('mbcrest');m.classList.remove('go');void m.offsetWidth;m.classList.add('go');}
function doDv(){ if(state!=='r_no')return; state='r_has';view();
 const i=document.querySelector('#crow .ic img');i.classList.add('dvbuy');}
function doEvo1(){ if(state!=='r_has')return; state='nop';view(); }
function doEvo(){ if(state!=='lit')return; state='ult';view(); }
function doTag(){ if(state!=='nop')return;   // buying the pendant sets the (still unlit) crest into its window
 const pop=document.getElementById('pop'),ic=pop.querySelector('#crow .ic img'),r0=ic.getBoundingClientRect(),pr=pop.getBoundingClientRect();
 ic.classList.remove('off');ic.style.transition='filter .4s';
 const f=document.createElement('img');f.src=crest(line);f.className='fly off';
 f.style.cssText+=`left:${r0.left-pr.left+150}px;top:${r0.top-pr.top-30}px;width:48px;height:48px;opacity:0`;pop.appendChild(f);
 setTimeout(()=>{f.style.opacity=1;},50);
 setTimeout(()=>{f.style.left=(r0.left-pr.left+8)+'px';f.style.top=(r0.top-pr.top+29)+'px';f.style.width='24px';f.style.height='24px';},450);
 setTimeout(()=>{state='off';view();},1500);}
document.getElementById('aDv').onclick=doDv;document.getElementById('aEvo1').onclick=doEvo1;document.getElementById('aAch').onclick=doAch;document.getElementById('aEvo').onclick=doEvo;document.getElementById('aTag').onclick=doTag;
document.getElementById('lines').innerHTML=LINES.map(l=>`<button data-k="${l}">${px(crest(l),CR,0.75)}${LKO[l]}</button>`).join('');
document.getElementById('states').innerHTML=STATES.map(([k,t])=>`<button data-k="${k}">${t}</button>`).join('');
document.querySelectorAll('#lines button').forEach(b=>b.onclick=()=>{line=b.dataset.k;view();});
document.querySelectorAll('#states button').forEach(b=>b.onclick=()=>{state=b.dataset.k;view();});
const q=new URLSearchParams(location.hash.slice(1));if(q.get('line'))line=q.get('line');if(q.get('state'))state=q.get('state');
gallery();view();
</script></body></html>"""
open(os.path.join(V, "crest-mockup.html"), "w").write(HTML.replace("__DATA__", json.dumps(data, ensure_ascii=False)))
print("written", os.path.join(V, "crest-mockup.html"))
