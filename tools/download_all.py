"""Download Adventure partner dot sprites from Wikimon. usage: download_all.py OUT_DIR"""
import json, os, sys, time, urllib.parse, urllib.request
UA = "DigiTokenBar-research/0.1"
OUT = sys.argv[1]
VB, DV, D3 = "Vital Bracelet", "Digivice -25th COLOR EVOLUTION-", "D-3 -25th COLOR EVOLUTION-"
PH = " (placeholder)"
S = ["0_baby1","1_baby2","2_rookie","3_champion","4_ultimate","5_mega"]
LINES = {  # (name, wikimon file, source); 6 stages then optional armor
 "agumon":  [("Botamon","Botamon vpet vb.png",VB),("Koromon","Koromon vpet vb.png",VB),("Agumon","Agumon vpet vb.png",VB),("Greymon","Greymon vpet vb.png",VB),("MetalGreymon","Metalgreymon vpet vb.png",VB),("WarGreymon","Wargreymon vpet vb.png",VB)],
 "gabumon": [("Punimon","Punimon vpet vb.png",VB),("Tsunomon","Tunomon vpet vb.png",VB),("Gabumon","Gabumon vpet vb.png",VB),("Garurumon","Garurumon vpet vb.png",VB),("WereGarurumon","Weregarurumon vpet vb.png",VB),("MetalGarurumon","Metalgarurumon vpet vb.png",VB)],
 "biyomon": [("Nyokimon","Nyokimon vpet vb.png",VB),("Yokomon","Pyocomon vpet vb.png",VB),("Biyomon","Piyomon vpet vb.png",VB),("Birdramon","Birdramon vpet vb.png",VB),("Garudamon","Garudamon vpet vb.png",VB),("Hououmon","Hououmon vpet vb.png",VB)],
 "tentomon":[("Pabumon","Bubbmon vpet vb.png",VB),("Motimon","Mochimon vpet vb.png",VB),("Tentomon","Tentomon vpet vb.png",VB),("Kabuterimon","Kabuterimon vpet vb.png",VB),("AtlurKabuterimon","Atlurkabuterimon red vpet vb.png",VB),("HerakleKabuterimon","Heraklekabuterimon vpet vb.png",VB)],
 "palmon":  [("Yuramon","Yuramon vpet vb.png",VB),("Tanemon","Tanemon vpet vb.png",VB),("Palmon","Palmon vpet vb.png",VB),("Togemon","Togemon vpet vb.png",VB),("Lillymon","Lilimon vpet vb.png",VB),("Rosemon","Rosemon vpet vb.png",VB)],
 "gomamon": [("Pichimon","Pitchmon vpet vb.png",VB),("Bukamon","Pukamon vpet vb.png",VB),("Gomamon","Gomamon vpet dv color.png",DV),("Ikkakumon","Ikkakumon vpet vb.png",VB),("Zudomon","Zudomon vpet vb.png",VB),("Vikemon","Vikemon vpet vb.png",VB)],
 "patamon": [("Poyomon","Poyomon vpet dmc.gif","Digital Monster COLOR"+PH),("Tokomon","Tokomon vpet dv color.png",DV),("Patamon","Patamon vpet vb.png",VB),("Angemon","Angemon vpet vb.png",VB),("HolyAngemon","Holyangemon vpet vb.png",VB),("Seraphimon","Seraphimon vpet vb.png",VB)],
 "tailmon": [("YukimiBotamon","Yukimibotamon vpet vb.png",VB),("Nyaromon","Nyaromon vpet dpc.gif","Pendulum COLOR"+PH),("Plotmon","Plotmon vpet d3 color.png",D3),("Tailmon","Tailmon vpet vb.png",VB),("Angewomon","Angewomon vpet vb.png",VB),("Holydramon","Holydramon vpet vb.png",VB)],
}
ARMOR = {"patamon":("Pegasusmon","Pegasmon vpet vb.png",VB), "tailmon":("Nefertimon","Nefertimon vpet vb.png",VB)}
entries = []
for line, sp in LINES.items():
    entries += [(line, st, *x) for st, x in zip(S, sp)]
    if line in ARMOR: entries.append((line, "x_armor", *ARMOR[line]))
def get(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": UA})) as r: return r.read()
info = {}
files = ["File:" + e[3] for e in entries]
for i in range(0, len(files), 25):
    d = json.loads(get("https://wikimon.net/api.php?" + urllib.parse.urlencode({"action":"query","titles":"|".join(files[i:i+25]),"prop":"imageinfo","iiprop":"url|size","format":"json"})))
    for p in d["query"]["pages"].values():
        if p.get("imageinfo"): info[p["title"].replace("File:","")] = p["imageinfo"][0]
    time.sleep(5)
manifest = []
for line, stage, name, f, src in entries:
    ii = info.get(f)
    if not ii: print("MISSING", line, name, f); continue
    os.makedirs(os.path.join(OUT, line), exist_ok=True)
    rel = f"{line}/{stage}_{name.lower()}{os.path.splitext(ii['url'])[1]}"
    dest = os.path.join(OUT, rel)
    if not os.path.exists(dest):
        open(dest, "wb").write(get(ii["url"])); time.sleep(5)
    manifest.append({"line":line,"stage":stage,"name":name,"file":rel,"size":[ii["width"],ii["height"]],"source":src.replace(PH,""),"wikimonFile":f,"url":ii["url"],"placeholder":src.endswith(PH)})
    print(f"ok {line:9} {stage:11} {name:18} {ii['width']}x{ii['height']}  {src}")
json.dump(manifest, open(os.path.join(OUT,"manifest.json"),"w"), indent=2, ensure_ascii=False)
print("total", len(manifest), "placeholders", sum(m["placeholder"] for m in manifest))
