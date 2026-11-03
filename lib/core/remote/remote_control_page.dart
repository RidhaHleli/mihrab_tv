/// Single-page web UI served to the phone. All visible text comes from the
/// `labels` object returned by `/api/settings`, so it follows the TV language.
const String remoteControlHtml = r'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<meta name="theme-color" content="#0f2a2e">
<title>MIHRAB</title>
<style>
:root{--bg:#0f2a2e;--card:#16393e;--line:#2b5a60;--gold:#d9b45a;--text:#f2ead7;--muted:#a9c0bf}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--text);font-family:system-ui,-apple-system,"Segoe UI",Tahoma,sans-serif;padding:16px 16px 96px;max-width:560px;margin-inline:auto}
h1{font-size:20px;color:var(--gold);margin:4px 0 16px;text-align:center;letter-spacing:1px}
section{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:14px;margin-bottom:14px}
h2{font-size:14px;color:var(--gold);margin:0 0 10px}
label{display:block;font-size:13px;color:var(--muted);margin:10px 0 4px}
input[type=text],input[type=number],select{width:100%;padding:12px;border-radius:10px;border:1px solid var(--line);background:#0f2a2e;color:var(--text);font-size:16px}
.row{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:8px 0}
.row span{font-size:15px}
.sw{position:relative;width:48px;height:28px;flex:none}
.sw input{opacity:0;width:100%;height:100%;position:absolute;margin:0;cursor:pointer}
.sw i{position:absolute;inset:0;background:#3b5b5f;border-radius:14px;transition:.2s;pointer-events:none}
.sw i::after{content:"";position:absolute;top:3px;inset-inline-start:3px;width:22px;height:22px;border-radius:50%;background:#fff;transition:.2s}
.sw input:checked+i{background:var(--gold)}
.sw input:checked+i::after{inset-inline-start:23px;background:#16393e}
input[type=range]{width:100%;accent-color:var(--gold)}
table{width:100%;border-collapse:collapse}
td,th{padding:6px 4px;font-size:14px}
th{color:var(--muted);font-weight:500;text-align:start}
td input{padding:8px;text-align:center}
.ann{display:flex;gap:8px;align-items:center;padding:6px 0;border-bottom:1px solid var(--line)}
.ann span{flex:1;font-size:14px;word-break:break-word}
button{border:0;border-radius:10px;padding:10px 14px;font-size:15px;cursor:pointer}
.ghost{background:transparent;color:#ff9b9b;border:1px solid #ff9b9b55}
.add{display:flex;gap:8px;margin-top:10px}
.add button{background:var(--gold);color:#16393e;font-weight:600;white-space:nowrap}
#bar{position:fixed;inset-inline:0;bottom:0;padding:12px 16px;background:linear-gradient(transparent,#0f2a2e 40%)}
#save{display:block;width:100%;max-width:528px;margin:auto;background:var(--gold);color:#16393e;font-weight:700;font-size:17px;padding:14px}
#msg{text-align:center;font-size:14px;margin-bottom:8px;min-height:18px;color:var(--gold)}
</style>
</head>
<body>
<h1>MIHRAB | محراب</h1>
<div id="app"></div>
<div id="bar"><div id="msg"></div><button id="save" type="button"></button></div>
<script>
(function(){
var token=new URLSearchParams(location.search).get('t')||'';
var app=document.getElementById('app'),msg=document.getElementById('msg'),saveBtn=document.getElementById('save');
var S=null,L={},M={},PR=['fajr','sunrise','dhuhr','asr','maghrib','isha'];
function el(t,c,x){var e=document.createElement(t);if(c)e.className=c;if(x!=null)e.textContent=x;return e}
function sec(title){var s=el('section');s.appendChild(el('h2',null,title));app.appendChild(s);return s}
function lab(p,t){var l=el('label',null,t);p.appendChild(l);return l}
function text(p,t,k,max){lab(p,t);var i=el('input');i.type='text';i.maxLength=max||80;i.value=S[k]||'';i.oninput=function(){S[k]=i.value};p.appendChild(i)}
function sel(p,t,k,opts,num){lab(p,t);var s=el('select');opts.forEach(function(o){var x=el('option',null,o[1]);x.value=o[0];s.appendChild(x)});s.value=String(S[k]);s.onchange=function(){S[k]=num?Number(s.value):s.value};p.appendChild(s)}
function tog(p,t,k){var r=el('div','row');r.appendChild(el('span',null,t));var w=el('label','sw');w.style.margin='0';var i=el('input');i.type='checkbox';i.checked=!!S[k];i.onchange=function(){S[k]=i.checked};w.appendChild(i);w.appendChild(el('i'));r.appendChild(w);p.appendChild(r)}
function num(p,t,k,min,max){lab(p,t);var i=el('input');i.type='number';i.min=min;i.max=max;i.value=S[k];i.oninput=function(){S[k]=Number(i.value)};p.appendChild(i)}
function render(){
 app.textContent='';
 var a=sec(L.appearance);
 text(a,L.display_name,'displayName');
 sel(a,L.language,'language',[['ar','العربية'],['fr','Français'],['en','English']]);
 sel(a,L.theme,'themeId',[['kairouan',L.theme_kairouan],['makkah',L.theme_makkah],['quds',L.theme_quds]]);
 var b=sec(L.adhan_section);
 tog(b,L.adhan_on,'adhanEnabled');tog(b,L.iqama_on,'iqamaEnabled');
 lab(b,L.volume);var v=el('input');v.type='range';v.min=0;v.max=100;v.value=Math.round(S.volume*100);v.oninput=function(){S.volume=v.value/100};b.appendChild(v);
 sel(b,L.calc_method,'calculationMethod',Object.keys(M).map(function(k){return[k,M[k]]}),true);
 var t=el('table');var h=el('tr');['','+/- '+L.minutes_unit,L.iqama_delays+' ('+L.minutes_unit+')'].forEach(function(x){h.appendChild(el('th',null,x))});t.appendChild(h);
 PR.forEach(function(p,ix){var r=el('tr');r.appendChild(el('td',null,L[p]));
  var c1=el('td'),i1=el('input');i1.type='number';i1.min=-30;i1.max=30;i1.value=S.adhanAdjustments[ix];i1.oninput=function(){S.adhanAdjustments[ix]=Number(i1.value)};c1.appendChild(i1);r.appendChild(c1);
  var c2=el('td');if(p!=='sunrise'){var i2=el('input');i2.type='number';i2.min=0;i2.max=60;i2.value=S.iqamaDelays[ix];i2.oninput=function(){S.iqamaDelays[ix]=Number(i2.value)};c2.appendChild(i2)}r.appendChild(c2);t.appendChild(r)});
 b.appendChild(t);
 num(b,L.jumuah_delay+' ('+L.minutes_unit+')','jumuahDelayMinutes',5,90);
 var c=sec(L.announcements);
 tog(c,L.announcements_on,'announcementsEnabled');tog(c,L.reminders_on,'dailyReminderEnabled');
 var list=el('div');c.appendChild(list);
 function drawList(){list.textContent='';if(!S.announcements.length){list.appendChild(el('label',null,L.no_announcements))}
  S.announcements.forEach(function(x,i){var r=el('div','ann');r.appendChild(el('span',null,x));var d=el('button','ghost',L.delete);d.type='button';d.onclick=function(){S.announcements.splice(i,1);drawList()};r.appendChild(d);list.appendChild(r)})}
 drawList();
 var ad=el('div','add'),ai=el('input');ai.type='text';ai.maxLength=200;ai.placeholder=L.announcement_hint;var ab=el('button',null,L.add);ab.type='button';
 ab.onclick=function(){var v=ai.value.trim();if(v&&S.announcements.length<20){S.announcements.push(v);ai.value='';drawList()}};
 ad.appendChild(ai);ad.appendChild(ab);c.appendChild(ad);
 var d=sec(L.ramadan_section);
 sel(d,L.ramadan_mode,'ramadanMode',[['auto',L.mode_auto],['on',L.mode_on],['off',L.mode_off]]);
 num(d,L.hijri_adjust,'hijriAdjustment',-2,2);num(d,L.imsak_minutes,'imsakMinutes',0,30);
 var e=sec(L.screen_section);tog(e,L.night_mode,'nightModeEnabled');
 saveBtn.textContent=L.save;
}
function api(opt){return fetch('/api/settings?t='+encodeURIComponent(token),opt)}
api().then(function(r){if(!r.ok)throw 0;return r.json()}).then(function(j){S=j.settings;L=j.labels;M=j.methods;render()}).catch(function(){app.textContent='Unauthorized / ‏غير مصرح';});
saveBtn.onclick=function(){saveBtn.disabled=true;
 api({method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(S)}).then(function(r){if(!r.ok)throw 0;return r.json()}).then(function(j){S=j.settings;L=j.labels;render();msg.textContent=L.remote_saved;setTimeout(function(){msg.textContent=''},2500)}).catch(function(){msg.textContent='Error'}).then(function(){saveBtn.disabled=false})};
})();
</script>
</body>
</html>''';
