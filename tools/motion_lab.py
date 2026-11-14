"""Build motion-lab.html next to the converted sprites. usage: motion_lab.py VECTOR_DIR"""
import json, os, sys
D = sys.argv[1]
m = json.load(open(os.path.join(D, "manifest.json")))
data = [{k: e[k] for k in ("line","stage","name","png","native","placeholder")} for e in m]
HTML = r"""<!DOCTYPE html><html><head><meta charset="utf-8"><title>Digimon motion lab</title><style>
body{font-family:-apple-system,sans-serif;background:#f4f4f2;color:#222;padding:20px;margin:0}
h2{margin:0 0 12px} .row{display:flex;gap:20px;align-items:flex-start;flex-wrap:wrap}
canvas{image-rendering:pixelated;background:#fff;border:1px solid #ccc}
.ctl{display:flex;flex-wrap:wrap;gap:6px;margin:10px 0;max-width:780px} button{padding:6px 10px;border:1px solid #bbb;background:#fff;border-radius:6px;cursor:pointer;font-size:13px}
button.on{background:#222;color:#fff;border-color:#222} select{padding:5px;font-size:13px}
.mb{display:flex;align-items:center;gap:6px;background:#e9e9ec;border:1px solid #ccc;height:24px;padding:0 10px;font:12px -apple-system;width:fit-content}
.mb canvas{border:0;background:transparent} pre{background:#fff;border:1px solid #ddd;padding:8px;font-size:11px;max-width:780px;max-height:180px;overflow:auto;white-space:pre-wrap}
small{color:#777}
</style></head><body>
<h2>디지몬 모션 랩 <small>원본 도트 크기 기준 · 1도트 단위 이동 · 4배 표시</small></h2>
<div class="ctl">
 <select id="line"></select><select id="stage"></select>
 <label><input type="checkbox" id="grid"> 도트 격자</label>
</div>
<div class="ctl" id="btns"></div>
<div class="row"><canvas id="cv"></canvas>
<div><b>메뉴바 크기</b><div class="mb"><canvas id="mb"></canvas><span>200.7M · 64%</span></div>
<p><small>재생 중: <b id="now"></b></small></p>
<p style="max-width:300px"><small>궁극체처럼 큰 디지몬은 22px 메뉴바에 맞추려면 축소해야 해서 도트가 뭉개집니다. 메뉴바용 작은 아이콘을 따로 둘지 정해야 합니다.</small></p></div></div>
<p><small>모션 프레임 데이터 (앱으로 옮길 때 그대로 쓰는 형식, 앞 8프레임)</small></p><pre id="spec"></pre>
<script>
const M = __MANIFEST__;
const STAGES=["0_baby1","1_baby2","2_rookie","3_champion","4_ultimate","5_mega","x_armor"];
const STAGE_KO={"0_baby1":"유년기 I","1_baby2":"유년기 II","2_rookie":"성장기","3_champion":"성숙기","4_ultimate":"완전체","5_mega":"궁극체","x_armor":"아머진화"};
const LINES=[...new Set(M.map(e=>e.line))];
const S=4, W=100, H=70, GROUND=64, CX=50;
const cv=document.getElementById('cv'); cv.width=W*S; cv.height=H*S; const ctx=cv.getContext('2d'); ctx.imageSmoothingEnabled=false;
const mb=document.getElementById('mb'); mb.width=108; mb.height=44; mb.style.width='54px'; mb.style.height='22px'; const mctx=mb.getContext('2d'); const MBC=44; // sprite centre in device px; room on the right for the badge
const off=document.createElement('canvas'); off.width=64; off.height=64; const octx=off.getContext('2d');
M.forEach(e=>{e.img=new Image(); e.img.src=e.png;});
const EGGS={};[...new Set(M.map(e=>e.line))].forEach(l=>{const i=new Image();i.src=`digitama/${l}.png`;EGGS[l]={name:'디지타마',native:[16,20],img:i};});

// ---- original pixel icons (drawn for this app, not from any game) ----
const ICONS={
 meat:{pal:{a:'#5a2d0c',b:'#c0603a',c:'#e8896a',w:'#f4ead8'},rows:[
  "..aaa....",".abcba...",".abbbba..","abcbbba..","abbbbba..",".abbbaww.","..aaa.www","......ww."]},
 heart:{pal:{a:'#e0245e',b:'#ff8fb1'},rows:[".aa.aa.","abaaaaa","aaaaaaa",".aaaaa.","..aaa..","...a..."]},
 z:{pal:{a:'#5566aa'},rows:["aaaa","..a.",".a..","aaaa"]},
 anger:{pal:{a:'#e03a3a'},rows:[".a.a.","aa.aa",".....","aa.aa",".a.a."]},
 note:{pal:{a:'#333'},rows:["..aa","..a.","..a.","aaa.","aa.."]},
 spark:{pal:{a:'#ffcc00',b:'#fff3a0'},rows:["..a..","..a..","aabaa","..a..","..a.."]},
 crack:{pal:{a:'#222'},rows:["a.....",".a..a.","..aa.a","..a..."]},
 excl:{pal:{a:'#ff8a00',b:'#7a3b00'},rows:[".aa.","baab","baab","baab",".bb.","....",".aa.","baab",".bb."]},
};
function drawIcon(c,name,x,y,cut=0,s=S){const ic=ICONS[name]; ic.rows.forEach((r,j)=>[...r].forEach((ch,i)=>{if(ch!=='.'&&i>=cut){c.fillStyle=ic.pal[ch];c.fillRect((x+i)*s,(y+j)*s,s,s);}}));}

// ---- placeholder digitama, generated per line (original design) ----
const EGG={agumon:['#f6e7c8','#e07b1a',0],gabumon:['#eef3ff','#3b6fd8',1],biyomon:['#fff0f5','#e86a9a',2],tentomon:['#f3efe6','#c0392b',0],
           palmon:['#f3fbe9','#4f9d2f',1],gomamon:['#f7f7ff','#8e6cc9',2],patamon:['#fff7e0','#e8a33a',0],tailmon:['#fffdf2','#c9a227',1]};
function makeEgg(line){const w=14,h=17,c=document.createElement('canvas');c.width=w;c.height=h;const g=c.getContext('2d');const [base,spot,pat]=EGG[line];
 for(let y=0;y<h;y++)for(let x=0;x<w;x++){const cy=h*0.56,nx=(x+.5-w/2)/(w/2),ny=(y+.5-cy)/(y<cy?cy:h-cy),r=nx*nx+ny*ny;if(r>1)continue;
  let col=base; const inner=r<=0.72;
  if(!inner) col='#2b2b2b';
  else if(pat===0&&((x+y*3)%6===0)&&y>2) col=spot;
  else if(pat===1&&(y===7||y===8||y===11)) col=spot;
  else if(pat===2&&((x+y)%4===0)&&y>4&&y<14) col=spot;
  else if(x>=3&&x<=4&&y>=3&&y<=5) col='#ffffff';
  g.fillStyle=col;g.fillRect(x,y,1,1);} return {name:'디지타마',native:[w,h],img:c};}

// ---- motions: list of frames {d:ms, dx, dy (dots), flip, mode, who, ov:[overlays], flash} ----
const meat=cut=>({i:'meat',ax:'right',ay:'ground',ox:3,oy:-8,cut});
const MOTIONS={
 idle:{loop:true,ko:'대기',f:()=>{const f=[];for(const flip of [false,true])for(let k=0;k<3;k++){f.push({d:500,flip});f.push({d:500,dy:-1,flip});}return f;}},
 walk:{loop:true,ko:'걷기',f:()=>{const f=[];let x=0,dir=1;for(let k=0;k<64;k++){x+=dir;if(Math.abs(x)>=16)dir=-dir;f.push({d:160,dx:x,dy:(k>>1)%2?-1:0,flip:dir<0});}return f;}},
 happy:{ko:'기쁨',f:()=>{const arc=[0,-3,-5,-6,-5,-3,0],f=[];for(let r=0;r<2;r++){arc.forEach((y,i)=>f.push({d:70,dy:y,ov:[{i:'note',ax:'right',ay:'top',ox:1,oy:-5-(i%2)}]}));f.push({d:220});}return f;}},
 eat:{ko:'먹기 (고기)',f:()=>{const f=[{d:500,ov:[meat(0)]}];for(let b=0;b<3;b++){f.push({d:160,dx:2,ov:[meat(b*3)]},{d:200,ov:[meat(b*3+3)]},{d:320,dy:-1,ov:[meat(b*3+3)]});}f.push({d:250,dy:-2},{d:250},{d:250,dy:-2},{d:400});return f;}},
 pet:{ko:'쓰다듬기',f:()=>{const f=[];for(let k=0;k<9;k++)f.push({d:130,dy:k%2?-1:0,ov:[{i:'heart',ax:'center',ay:'top',ox:-3,oy:-4-k}]});f.push({d:250,dy:-2},{d:400});return f;}},
 sleep:{loop:true,ko:'수면',f:()=>{const f=[];for(let k=0;k<8;k++)f.push({d:550,mode:'dim',ov:[{i:'z',ax:'right',ay:'top',ox:(k%4),oy:-2-(k%4)*2},...(k%4>1?[{i:'z',ax:'right',ay:'top',ox:4+(k%2),oy:-9}]:[])]});return f;}},
 sulk:{ko:'삐짐',f:()=>{const ang={i:'anger',ax:'right',ay:'top',ox:-3,oy:-2},f=[];for(let k=0;k<12;k++)f.push({d:80,dx:k%2?1:-1,ov:k%4<2?[ang]:[]});f.push({d:700,ov:[ang]});return f;}},
 evolve:{ko:'진화',f:()=>{const f=[];for(let k=0;k<8;k++)f.push({d:80,dx:k%2?1:-1});
   [340,280,220,170,130,100,80,65,55,50,45,45].forEach((d,i)=>f.push({d,mode:'black',who:i%2?'next':'cur'}));
   f.push({d:70,flash:true},{d:70,mode:'white',who:'next'},{d:70,flash:true},{d:140,mode:'white',who:'next'});
   const sp=[{i:'spark',ax:'left',ay:'top',ox:-5,oy:1},{i:'spark',ax:'right',ay:'top',ox:1,oy:6},{i:'spark',ax:'left',ay:'mid',ox:-6,oy:4}];
   f.push({d:500,who:'next',ov:sp},{d:300,who:'next',dy:-2,ov:sp.slice(1)},{d:300,who:'next'},{d:300,who:'next',dy:-2},{d:900,who:'next'});return f;}},
 devolve:{ko:'복귀 (성장기로)',f:()=>{const f=[];[200,160,120,90,70,60].forEach((d,i)=>f.push({d,mode:'black',who:i%2?'rookie':'cur'}));
   f.push({d:70,flash:true},{d:300,who:'rookie',dy:-1},{d:300,who:'rookie'},{d:300,who:'rookie',dy:-1},{d:600,who:'rookie'});return f;}},
 ready:{loop:true,ko:'진화 가능 (!)',f:()=>{const ex=b=>({i:'excl',ax:'center',ay:'top',ox:-2,oy:-10-b,bob:b,badge:true});const f=[];
   for(let k=0;k<4;k++)f.push({d:300,ov:[ex(0)]},{d:300,dy:-1,ov:[ex(1)]});f.push({d:150,dy:-2,ov:[ex(2)]},{d:150,ov:[ex(0)]},{d:300},{d:300,dy:-1});return f;}},
 hatch:{ko:'부화',f:()=>{const f=[{d:700,who:'egg'}];[300,260,220,180,150,120,100,90,80,70,60,60].forEach((d,i)=>f.push({d,who:'egg',dx:i%2?1:-1,ov:i>5?[{i:'crack',ax:'center',ay:'mid',ox:-3,oy:-3}]:[]}));
   f.push({d:80,flash:true},{d:80,who:'egg',mode:'white'},{d:80,flash:true});
   f.push({d:400,who:'baby',dy:-2},{d:300,who:'baby'},{d:250,who:'baby',dy:-2},{d:250,who:'baby'},{d:800,who:'baby',ov:[{i:'heart',ax:'center',ay:'top',ox:-3,oy:-8}]});return f;}},
};
MOTIONS.auto={loop:true,ko:'자동 (V-Pet처럼)',f:()=>[...MOTIONS.idle.f(),...MOTIONS.walk.f().slice(0,32),...MOTIONS.idle.f().slice(0,6),...MOTIONS.happy.f(),...MOTIONS.idle.f()]};

// ---- state & UI ----
const selL=document.getElementById('line'), selS=document.getElementById('stage');
LINES.forEach(l=>selL.add(new Option(l,l)));
function fillStages(){selS.innerHTML='';selS.add(new Option('디지타마','egg'));M.filter(e=>e.line===selL.value).forEach(e=>selS.add(new Option(`${STAGE_KO[e.stage]} · ${e.name}`,e.stage)));selS.value='2_rookie';}
selL.onchange=()=>{fillStages();play(cur);}; selS.onchange=()=>play(cur); fillStages();
const entry=st=>M.find(e=>e.line===selL.value&&e.stage===st);
function resolve(who){const lineMain=M.filter(e=>e.line===selL.value&&e.stage!=='x_armor');const c=entry(selS.value);
 if(who==='egg'||(who==='cur'&&selS.value==='egg'))return EGGS[selL.value]; if(who==='baby')return entry('0_baby1'); if(who==='rookie')return entry('2_rookie');
 if(who==='next'&&selS.value==='egg')return entry('0_baby1');
 if(who==='next'){const i=lineMain.indexOf(c);return lineMain[Math.min(i+1,lineMain.length-1)]||c;} return c;}
const eggCache={};function makeEggCached(l){return eggCache[l]||(eggCache[l]=makeEgg(l));}
const btns=document.getElementById('btns');
Object.entries(MOTIONS).forEach(([k,v])=>{const b=document.createElement('button');b.textContent=v.ko;b.dataset.k=k;b.onclick=()=>play(k);btns.appendChild(b);});
let cur='auto',frames=[],fi=0,t0=0;
function play(k){cur=k;frames=MOTIONS[k].f();fi=0;t0=performance.now();
 document.querySelectorAll('#btns button').forEach(b=>b.classList.toggle('on',b.dataset.k===k));
 document.getElementById('now').textContent=MOTIONS[k].ko;
 document.getElementById('spec').textContent=frames.slice(0,8).map(f=>JSON.stringify(f)).join('\n');}

function spriteBox(e,fr){const [w,h]=e.native;return {w,h,x:Math.round(CX-w/2+(fr.dx||0)),y:Math.round(GROUND-h+(fr.dy||0))};}
function drawSprite(c,e,fr,s,ox=0,oy=0){const {w,h,x,y}=spriteBox(e,fr);const img=e.img;if(img instanceof HTMLImageElement&&!img.complete)return;
 octx.clearRect(0,0,64,64);octx.globalCompositeOperation='source-over';octx.drawImage(img,0,0);
 if(fr.mode==='black'||fr.mode==='white'){octx.globalCompositeOperation='source-in';octx.fillStyle=fr.mode==='black'?'#151515':'#ffffff';octx.fillRect(0,0,64,64);octx.globalCompositeOperation='source-over';}
 c.save(); if(fr.mode==='dim')c.filter='brightness(0.55)';
 const px=(x+ox)*s,py=(y+oy)*s; if(fr.flip){c.translate(px*2+w*s,0);c.scale(-1,1);} c.drawImage(off,0,0,w,h,px,py,w*s,h*s); c.restore();}
function render(fr){ctx.clearRect(0,0,cv.width,cv.height);
 ctx.fillStyle='#e6e2d6';for(let x=0;x<W;x+=2)ctx.fillRect(x*S,(GROUND)*S,S,S);
 const e=resolve(fr.who||'cur');drawSprite(ctx,e,fr,S);
 const b=spriteBox(e,fr);
 (fr.ov||[]).forEach(o=>{const ax=o.ax==='right'?b.x+b.w:o.ax==='left'?b.x:b.x+Math.round(b.w/2);const ay=o.ay==='top'?b.y:o.ay==='mid'?b.y+Math.round(b.h/2):GROUND;
  let ix=ax+(o.ox||0),iy=ay+(o.oy||0);
  // "!" badge floats diagonally off the sprite's top-right corner (outside the body), bobbing upward
  if(o.badge){ix=Math.min(b.x+b.w+1,W-5);iy=Math.max(3,b.y-5)-(o.bob||0);}
  drawIcon(ctx,o.i,ix,iy,o.cut||0);});
 if(fr.flash){ctx.fillStyle='#fff';ctx.fillRect(0,0,cv.width,cv.height);}
 if(document.getElementById('grid').checked){ctx.fillStyle='rgba(0,0,0,.06)';for(let x=0;x<W;x++)ctx.fillRect(x*S,0,1,cv.height);for(let y=0;y<H;y++)ctx.fillRect(0,y*S,cv.width,1);}
 ctx.fillStyle='#999';ctx.font='12px -apple-system';ctx.fillText(e.name+(e.placeholder?'  (임시 이미지)':''),8,16);
 // menu bar: fit 44 device px (22pt @2x); integer 1x/2x when possible
 mctx.clearRect(0,0,mb.width,mb.height);const [w,h]=e.native;const s=h<=22?2:h<=44?1:44/h;mctx.imageSmoothingEnabled=s<1;
 const mfr={...fr,dx:0};const bx=spriteBox(e,mfr);mctx.save();mctx.translate(MBC-(CX*s),mb.height-(GROUND*s)-1);drawSprite(mctx,e,{...mfr,dy:(fr.dy||0)<0?-1:0},s);mctx.restore();
 // menu bar: "!" sits diagonally off the sprite's top-right, outside the body (2 device px per dot)
 (fr.ov||[]).filter(o=>o.badge).forEach(o=>{const right=MBC-CX*s+(bx.x+bx.w)*s;const dx=Math.min(Math.ceil(right/2)+1,mb.width/2-4);drawIcon(mctx,o.i,dx,3-(o.bob||0),0,2);});}
function tick(now){if(frames.length){while(now-t0>=frames[fi].d){t0+=frames[fi].d;fi++;if(fi>=frames.length){if(MOTIONS[cur].loop)fi=0;else{play('idle');break;}}}render(frames[fi]);}requestAnimationFrame(tick);}
play('auto');requestAnimationFrame(tick);
</script></body></html>"""
open(os.path.join(D, "motion-lab.html"), "w").write(HTML.replace("__MANIFEST__", json.dumps(data, ensure_ascii=False)))
print("written", os.path.join(D, "motion-lab.html"))
