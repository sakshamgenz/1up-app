import { useState, useEffect, useRef } from "react";

const CATEGORIES = [
  { label: "Work",     emoji: "💼", color: "#FFB347" },
  { label: "Study",   emoji: "📚", color: "#87CEEB" },
  { label: "Health",  emoji: "🏃", color: "#98FB98" },
  { label: "Personal",emoji: "⭐", color: "#DDA0DD" },
  { label: "Fun",     emoji: "🎮", color: "#F08080" },
];

const PRIORITIES = [
  { label: "Low",    color: "#98FB98", icon: "🟢" },
  { label: "Medium", color: "#FFD700", icon: "🟡" },
  { label: "High",   color: "#FF6B6B", icon: "🔴" },
];

const REPEAT_OPTIONS = ["Never", "Daily", "Weekly", "Weekdays", "Weekends"];

const BG_DOTS = [
  { r:8,  c:"#FFD93D", l:"8%",  t:"12%", a:3.2 },
  { r:5,  c:"#FF6B6B", l:"78%", t:"7%",  a:4.1 },
  { r:11, c:"#87CEEB", l:"55%", t:"18%", a:2.8 },
  { r:6,  c:"#98FB98", l:"22%", t:"35%", a:3.6 },
  { r:9,  c:"#DDA0DD", l:"88%", t:"40%", a:4.5 },
  { r:7,  c:"#FFB347", l:"40%", t:"58%", a:2.5 },
  { r:5,  c:"#F08080", l:"12%", t:"72%", a:3.9 },
  { r:10, c:"#FFD93D", l:"70%", t:"80%", a:3.1 },
];

// Sound Manager using original smooth wave settings
const playSound = (type) => {
  try {
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    if (!AudioContext) return null;
    const ctx = new AudioContext();
    const now = ctx.currentTime;
    
    if (type === "add") {
      [261.63, 329.63, 392.00, 523.25].forEach((freq, i) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "sine";
        osc.frequency.setValueAtTime(freq, now + i * 0.08);
        gain.gain.setValueAtTime(0.1, now + i * 0.08);
        gain.gain.exponentialRampToValueAtTime(0.01, now + i * 0.08 + 0.1);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now + i * 0.08);
        osc.stop(now + i * 0.08 + 0.1);
      });
    } else if (type === "done") {
      // Restored clear complete audio setup
      [587.33, 880.00].forEach((freq, i) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "sine"; // Kept sweet and smooth
        osc.frequency.setValueAtTime(freq, now + i * 0.1);
        gain.gain.setValueAtTime(0.15, now + i * 0.1);
        gain.gain.exponentialRampToValueAtTime(0.01, now + i * 0.1 + 0.2);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now + i * 0.1);
        osc.stop(now + i * 0.1 + 0.25);
      });
    } else if (type === "alarm_pulse") {
      // Reverted back to the original pleasing soft sound signature
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "sine"; 
      osc.frequency.setValueAtTime(440, now); 
      gain.gain.setValueAtTime(0.15, now);
      gain.gain.exponentialRampToValueAtTime(0.01, now + 0.4);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 0.45);
    }
  } catch (e) {
    console.error("Audio engine error:", e);
  }
};

function RocketSVG({ style }) {
  return (
    <svg viewBox="0 0 60 80" style={style} fill="none">
      <ellipse cx="30" cy="32" rx="14" ry="22" fill="#FF6B6B" stroke="#E05555" strokeWidth="1.5"/>
      <polygon points="30,4 16,32 44,32" fill="#FF8C8C" stroke="#E05555" strokeWidth="1"/>
      <rect x="22" y="46" width="16" height="14" rx="4" fill="#FFB347" stroke="#E09030" strokeWidth="1.5"/>
      <ellipse cx="30" cy="30" rx="7" ry="10" fill="#87CEEB" stroke="#5AABCC" strokeWidth="1"/>
      <polygon points="16,50 8,62 22,58" fill="#FFB347" stroke="#E09030" strokeWidth="1"/>
      <polygon points="44,50 52,62 38,58" fill="#FFB347" stroke="#E09030" strokeWidth="1"/>
      <ellipse cx="30" cy="64" rx="8" ry="5" fill="#FF6B6B" opacity="0.35"/>
    </svg>
  );
}

function StarSVG({ style }) {
  return (
    <svg viewBox="0 0 40 40" style={style} fill="none">
      <polygon points="20,2 24,15 38,15 27,23 31,37 20,29 9,37 13,23 2,15 16,15"
        fill="#FFD93D" stroke="#F4A823" strokeWidth="1.5"/>
      <circle cx="20" cy="20" r="5" fill="#FFF3B0" opacity="0.6"/>
    </svg>
  );
}

function CatSVG({ style }) {
  return (
    <svg viewBox="0 0 80 80" style={style} fill="none">
      <ellipse cx="40" cy="50" rx="28" ry="24" fill="#FFD93D" stroke="#F4A823" strokeWidth="1.5"/>
      <ellipse cx="40" cy="36" rx="22" ry="20" fill="#FFD93D" stroke="#F4A823" strokeWidth="1.5"/>
      <polygon points="22,22 18,8 30,18" fill="#FFD93D" stroke="#F4A823" strokeWidth="1.5"/>
      <polygon points="58,22 62,8 50,18" fill="#FFD93D" stroke="#F4A823" strokeWidth="1.5"/>
      <polygon points="22,22 19,10 29,19" fill="#FFB347"/>
      <polygon points="58,22 61,10 51,19" fill="#FFB347"/>
      <ellipse cx="32" cy="34" rx="5" ry="6" fill="white"/>
      <ellipse cx="48" cy="34" rx="5" ry="6" fill="white"/>
      <ellipse cx="32" cy="35" rx="3" ry="4" fill="#333"/>
      <ellipse cx="48" cy="35" rx="3" ry="4" fill="#333"/>
      <circle cx="33" cy="34" r="1" fill="white"/>
      <circle cx="49" cy="34" r="1" fill="white"/>
      <ellipse cx="40" cy="44" rx="5" ry="3" fill="#FF9999"/>
      <path d="M35,44 Q40,48 45,44" stroke="#333" strokeWidth="1" fill="none"/>
      <line x1="20" y1="42" x2="8"  y2="38" stroke="#F4A823" strokeWidth="1"/>
      <line x1="20" y1="44" x2="7"  y2="44" stroke="#F4A823" strokeWidth="1"/>
      <line x1="20" y1="46" x2="8"  y2="50" stroke="#F4A823" strokeWidth="1"/>
      <line x1="60" y1="42" x2="72" y2="38" stroke="#F4A823" strokeWidth="1"/>
      <line x1="60" y1="44" x2="73" y2="44" stroke="#F4A823" strokeWidth="1"/>
      <line x1="60" y1="46" x2="72" y2="50" stroke="#F4A823" strokeWidth="1"/>
      <path d="M50,62 Q60,55 65,68" stroke="#F4A823" strokeWidth="2" fill="none" strokeLinecap="round"/>
    </svg>
  );
}

function PlantSVG({ style }) {
  return (
    <svg viewBox="0 0 60 80" style={style} fill="none">
      <rect x="22" y="56" width="16" height="18" rx="3" fill="#8B6914" stroke="#6B4F10" strokeWidth="1"/>
      <ellipse cx="30" cy="50" rx="12" ry="14" fill="#5DBB63" stroke="#3D9943" strokeWidth="1.5"/>
      <ellipse cx="18" cy="46" rx="10" ry="12" fill="#6DC96E" stroke="#3D9943" strokeWidth="1.5"/>
      <ellipse cx="42" cy="46" rx="10" ry="12" fill="#6DC96E" stroke="#3D9943" strokeWidth="1.5"/>
      <ellipse cx="30" cy="36" rx="10" ry="12" fill="#7DD87E" stroke="#3D9943" strokeWidth="1.5"/>
      <circle  cx="30" cy="30" r="6" fill="#FFD93D" stroke="#F4A823" strokeWidth="1"/>
    </svg>
  );
}

function TaskCard({ task, onCheck, onClick, done }) {
  const cat = CATEGORIES[task.category];
  const pri = PRIORITIES[task.priority];
  return (
    <div
      onClick={onClick}
      style={{
        background: "white",
        borderRadius: 20,
        padding: "14px 16px",
        marginBottom: 10,
        boxShadow: "0 3px 14px rgba(0,0,0,0.06)",
        border: `2px solid ${done ? "#F0EBE3" : cat.color + "55"}`,
        display: "flex",
        alignItems: "center",
        gap: 12,
        opacity: done ? 0.65 : 1,
        cursor: "pointer",
        transition: "transform 0.15s, box-shadow 0.15s",
      }}
    >
      <div
        onClick={onCheck}
        style={{
          width: 30, height: 30, borderRadius: "50%", flexShrink: 0,
          border: `2.5px solid ${done ? "#98FB98" : cat.color}`,
          background: done ? "#98FB98" : "transparent",
          display: "flex", alignItems: "center", justifyContent: "center",
          cursor: "pointer",
          boxShadow: done ? "0 2px 8px rgba(98,219,98,0.35)" : "none",
        }}
      >
        {done && (
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
            <path d="M2 7l4 4 6-6" stroke="white" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
      </div>

      <div style={{ flex: 1, minWidth: 0 }}>
        <p style={{
          fontSize: 15, fontWeight: 700, color: "#333",
          textDecoration: done ? "line-through" : "none",
          whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
        }}>
          {task.title}
        </p>
        <div style={{ display: "flex", gap: 6, alignItems: "center", marginTop: 3 }}>
          <span style={{ fontSize: 11, color: "#BBAA99", fontWeight: 700 }}>⏰ {task.time}</span>
          <span style={{ color: "#DDD", fontSize: 10 }}>•</span>
          <span style={{ fontSize: 11, color: "#BBAA99", fontWeight: 700 }}>{cat.emoji} {cat.label}</span>
          {task.repeat !== "Never" && (
            <>
              <span style={{ color: "#DDD", fontSize: 10 }}>•</span>
              <span style={{ fontSize: 11, color: "#BBAA99", fontWeight: 700 }}>🔁 {task.repeat}</span>
            </>
          )}
        </div>
      </div>

      <div style={{
        width: 10, height: 10, borderRadius: "50%", flexShrink: 0,
        background: pri.color,
        boxShadow: `0 2px 6px ${pri.color}88`,
      }} />
    </div>
  );
}

function Box({ label, children }) {
  return (
    <div style={{
      background: "white", borderRadius: 20, padding: "14px 18px",
      boxShadow: "0 3px 14px rgba(0,0,0,0.05)", border: "2px solid #F0E8D8",
    }}>
      <p style={{ fontSize: 11, fontWeight: 900, color: "#C0A888", letterSpacing: 0.5 }}>{label}</p>
      {children}
    </div>
  );
}

export default function App() {
  const [screen, setScreen]       = useState("home");
  
  const [tasks,  setTasks]        = useState(() => {
    const saved = localStorage.getItem("oneup_tasks");
    if (saved) {
      try { return JSON.parse(saved); } catch(e) { console.error(e); }
    }
    return [
      { id:1, title:"Morning Yoga 🧘",  time:"07:00", category:2, priority:1, repeat:"Daily",    note:"",               done:false },
      { id:2, title:"Team Standup",     time:"09:30", category:0, priority:2, repeat:"Weekdays", note:"Meeting room B", done:false },
      { id:3, title:"Read 30 pages 📖", time:"20:00", category:1, priority:0, repeat:"Daily",    note:"",               done:true  },
    ];
  });

  const [form,     setForm]       = useState({ title:"", time:"", category:0, priority:1, repeat:"Never", note:"" });
  const [selectedId, setSelectedId] = useState(null);
  const [filterCat,setFilterCat]  = useState(null);
  const [success,  setSuccess]    = useState(false);
  const [lastTriggeredAlarm, setLastTriggeredAlarm] = useState("");
  
  const [activeAlarmTask, setActiveAlarmTask] = useState(null);
  const alarmSoundInterval = useRef(null);

  useEffect(() => {
    localStorage.setItem("oneup_tasks", JSON.stringify(tasks));
  }, [tasks]);

  useEffect(() => {
    if ("Notification" in window && Notification.permission === "default") {
      Notification.requestPermission();
    }
  }, []);

  // Alarm core interval
  useEffect(() => {
    const timer = setInterval(() => {
      const nowTime = new Date();
      const currentHM = nowTime.toTimeString().slice(0, 5); 
      const dayOfWeek = nowTime.getDay(); 

      if (activeAlarmTask || currentHM === lastTriggeredAlarm) return;

      tasks.forEach(task => {
        if (!task.done && task.time === currentHM) {
          let shouldTrigger = true;
          if (task.repeat === "Weekdays" && (dayOfWeek === 0 || dayOfWeek === 6)) shouldTrigger = false;
          if (task.repeat === "Weekends" && (dayOfWeek > 0 && dayOfWeek < 6)) shouldTrigger = false;
          
          if (shouldTrigger) {
            setLastTriggeredAlarm(currentHM);
            setActiveAlarmTask(task);
            
            if ("Notification" in window && Notification.permission === "granted") {
              new Notification(`⏰ Task Due: ${task.title}`, {
                body: `It's ${task.time}! Time to start working.`,
                icon: "⚡"
              });
            }
          }
        }
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [tasks, lastTriggeredAlarm, activeAlarmTask]);

  // Audio loop hook
  useEffect(() => {
    if (activeAlarmTask) {
      playSound("alarm_pulse");
      alarmSoundInterval.current = setInterval(() => {
        playSound("alarm_pulse");
      }, 900); // Relaxed rhythm match for the classic sound signature
    } else {
      if (alarmSoundInterval.current) {
        clearInterval(alarmSoundInterval.current);
        alarmSoundInterval.current = null;
      }
    }

    return () => {
      if (alarmSoundInterval.current) clearInterval(alarmSoundInterval.current);
    };
  }, [activeAlarmTask]);

  const dismissAlarm = () => {
    setActiveAlarmTask(null);
  };

  const now       = new Date();
  const dateStr   = now.toLocaleDateString("en-US", { weekday:"long", month:"long", day:"numeric" });
  const doneCount = tasks.filter(t => t.done).length;
  const progress  = tasks.length ? Math.round((doneCount / tasks.length) * 100) : 0;
  const filtered  = filterCat === null ? tasks : tasks.filter(t => t.category === filterCat);
  const pending   = filtered.filter(t => !t.done);
  const completed = filtered.filter(t =>  t.done);

  const selected = tasks.find(t => t.id === selectedId);

  const save = () => {
    if (!form.title.trim() || !form.time) return;
    setTasks(p => [...p, { ...form, id: Date.now(), done: false }]);
    playSound("add"); 
    setForm({ title:"", time:"", category:0, priority:1, repeat:"Never", note:"" });
    setSuccess(true);
    setTimeout(() => { setSuccess(false); setScreen("home"); }, 950);
  };

  const toggle = id => {
    setTasks(p => p.map(t => {
      if (t.id === id) {
        const nextDoneState = !t.done;
        if (nextDoneState) {
          playSound("done"); // Fixed: Sound engine context ensures execution
        }
        return { ...t, done: nextDoneState };
      }
      return t;
    }));
  };
  
  const remove = id => { setTasks(p => p.filter(t => t.id !== id)); setScreen("home"); };

  return (
    <div style={{
      minHeight: "100vh", background: "#F8F5F0",
      fontFamily: "'Nunito', sans-serif",
      maxWidth: 430, margin: "0 auto",
      position: "relative", overflowX: "hidden",
    }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Nunito:wght=400;600;700;800;900&family=Fredoka+One&display=swap');
        * { box-sizing: border-box; margin: 0; padding: 0; }
        @keyframes float { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-12px)} }
        @keyframes wiggle { 0%,100%{transform:rotate(-6deg)} 50%{transform:rotate(6deg)} }
        @keyframes bounce { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-9px)} }
        @keyframes slideUp { from{transform:translateY(50px);opacity:0} to{transform:translateY(0);opacity:1} }
        @keyframes popIn { 0%{transform:scale(0.6);opacity:0} 70%{transform:scale(1.08)} 100%{transform:scale(1);opacity:1} }
        @keyframes successPop { 0%{transform:scale(0)} 70%{transform:scale(1.15)} 100%{transform:scale(1)} }
        @keyframes pulseRing { 0% { transform: scale(0.95); opacity: 0.5; } 50% { transform: scale(1.1); opacity: 0.8; } 100% { transform: scale(0.95); opacity: 0.5; } }
        input,textarea { outline:none; font-family:'Nunito',sans-serif; }
        ::-webkit-scrollbar { width:3px; }
        ::-webkit-scrollbar-thumb { background:#E0D5C8; border-radius:4px; }
      `}</style>

      {/* bg dots */}
      <div style={{ position:"fixed", inset:0, pointerEvents:"none", zIndex:0, overflow:"hidden" }}>
        {BG_DOTS.map((d,i) => (
          <div key={i} style={{
            position:"absolute", width:d.r*2, height:d.r*2, borderRadius:"50%",
            background:d.c, opacity:0.18, left:d.l, top:d.t,
            animation:`float ${d.a}s ease-in-out ${i*0.3}s infinite`,
          }}/>
        ))}
      </div>

      {/* ── ALARM MODAL OVERLAY ── */}
      {activeAlarmTask && (
        <div style={{
          position: "fixed", inset: 0, background: "rgba(255, 140, 0, 0.96)",
          display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
          zIndex: 9999, padding: 24, textAlign: "center", color: "white",
          animation: "slideUp 0.3s ease-out"
        }}>
          <div style={{
            width: 120, height: 120, borderRadius: "50%", background: "rgba(255,255,255,0.2)",
            display: "flex", alignItems: "center", justifyContent: "center", fontSize: 54,
            marginBottom: 24, animation: "bounce 1.5s ease-in-out infinite, pulseRing 2s infinite"
          }}>
            {CATEGORIES[activeAlarmTask.category]?.emoji || "⏰"}
          </div>

          <h1 style={{ fontFamily: "'Fredoka One'", fontSize: 28, marginBottom: 8, letterSpacing: 0.5 }}>
            Time to Core! ⚡
          </h1>
          <p style={{ fontSize: 18, opacity: 0.9, fontWeight: 700, marginBottom: 24 }}>
            Scheduled for {activeAlarmTask.time}
          </p>

          <div style={{
            background: "white", color: "#333", borderRadius: 24, width: "100%",
            padding: "24px 20px", boxShadow: "0 10px 30px rgba(0,0,0,0.15)", marginBottom: 40
          }}>
            <p style={{ fontSize: 12, fontWeight: 800, color: "#B08860", marginBottom: 6, letterSpacing: 1 }}>
              CURRENT MISSION
            </p>
            <h2 style={{ fontSize: 22, fontWeight: 900, color: "#FF8C00", lineHeight: 1.3 }}>
              {activeAlarmTask.title}
            </h2>
            {activeAlarmTask.note && (
              <p style={{ fontSize: 14, color: "#666", marginTop: 10, fontStyle: "italic" }}>
                "{activeAlarmTask.note}"
              </p>
            )}
          </div>

          <button
            onClick={dismissAlarm}
            style={{
              background: "white", color: "#FF8C00", border: "none",
              borderRadius: 30, padding: "18px 44px", fontFamily: "'Fredoka One'",
              fontSize: 20, cursor: "pointer", boxShadow: "0 6px 25px rgba(0,0,0,0.2)",
              transition: "transform 0.1s", transform: "scale(1)"
            }}
            onMouseDown={(e) => e.currentTarget.style.transform = "scale(0.96)"}
            onMouseUp={(e) => e.currentTarget.style.transform = "scale(1)"}
          >
            I'm Starting Work! 🚀
          </button>
        </div>
      )}

      {/* ── HOME ── */}
      {screen === "home" && (
        <div style={{ position:"relative", zIndex:1, paddingBottom:110 }}>

          {/* header */}
          <div style={{
            background:"linear-gradient(135deg,#FFF9F2,#FFF3E0)",
            borderBottom:"2px solid #EDE5D8",
            padding:"22px 20px 18px",
            position:"relative", overflow:"hidden",
          }}>
            <StarSVG style={{ position:"absolute", right:28, top:16, width:26, animation:"wiggle 2.2s ease-in-out infinite" }}/>
            <StarSVG style={{ position:"absolute", right:60, top:30, width:16, opacity:0.6, animation:"wiggle 3s ease-in-out 0.5s infinite" }}/>

            <div style={{ display:"flex", alignItems:"center", gap:10, marginBottom:6 }}>
              <div style={{
                background:"#FF8C00", borderRadius:14, padding:"4px 14px",
                display:"inline-flex", alignItems:"center", gap:6,
                boxShadow:"0 4px 14px rgba(255,140,0,0.35)",
              }}>
                <RocketSVG style={{ width:20, height:20 }}/>
                <span style={{ fontFamily:"'Fredoka One'", color:"white", fontSize:24, letterSpacing:1 }}>1UP</span>
              </div>
              <CatSVG style={{ width:40, height:40, animation:"bounce 2.4s ease-in-out infinite" }}/>
            </div>

            <p style={{ color:"#B08860", fontSize:12.5, fontWeight:700, marginBottom:12 }}>{dateStr}</p>

            <div style={{ background:"#EDE5D5", borderRadius:20, height:13, overflow:"hidden", marginBottom:5 }}>
              <div style={{
                height:"100%", width:`${progress}%`,
                background:"linear-gradient(90deg,#FF8C00,#FFD93D)",
                borderRadius:20, transition:"width 0.6s ease",
                position:"relative",
              }}>
                {progress > 4 && (
                  <div style={{
                    position:"absolute", right:-3, top:-2,
                    width:17, height:17, borderRadius:"50%",
                    background:"#FF8C00", border:"2.5px solid white",
                    boxShadow:"0 2px 8px rgba(255,140,0,0.45)",
                  }}/>
                )}
              </div>
            </div>
            <p style={{ color:"#C09070", fontSize:12, fontWeight:800 }}>
              {doneCount}/{tasks.length} done · {progress}% 🎯
            </p>
          </div>

          {/* category filter */}
          <div style={{ padding:"14px 16px 0", display:"flex", gap:8, overflowX:"auto" }}>
            <div
              onClick={() => setFilterCat(null)}
              style={{
                background: filterCat===null ? "#FF8C00" : "white",
                border:`2px solid ${filterCat===null ? "#FF8C00" : "#EEE5D8"}`,
                borderRadius:20, padding:"5px 13px",
                fontSize:12, fontWeight:700, whiteSpace:"nowrap",
                color: filterCat===null ? "white" : "#999",
                cursor:"pointer",
              }}>All ✨</div>
            {CATEGORIES.map((c,i) => (
              <div key={i}
                onClick={() => setFilterCat(filterCat===i ? null : i)}
                style={{
                  background: filterCat===i ? c.color : "white",
                  border:`2px solid ${filterCat===i ? c.color : "#EEE5D8"}`,
                  borderRadius:20, padding:"5px 13px",
                  fontSize:12, fontWeight:700, whiteSpace:"nowrap",
                  color: filterCat===i ? "white" : "#999",
                  cursor:"pointer",
                  boxShadow: filterCat===i ? `0 4px 12px ${c.color}55` : "none",
                }}>{c.emoji} {c.label}</div>
            ))}
          </div>

          <div style={{ display:"flex", justifyContent:"flex-end", paddingRight:14, marginTop:4 }}>
            <PlantSVG style={{ width:38, height:38, opacity:0.6 }}/>
          </div>

          {/* tasks */}
          <div style={{ padding:"4px 14px 0" }}>
            {filtered.length === 0 && (
              <div style={{ textAlign:"center", padding:"44px 20px", color:"#C5B8A8" }}>
                <div style={{ fontSize:54, marginBottom:12 }}>🌟</div>
                <p style={{ fontFamily:"'Fredoka One'", fontSize:20, marginBottom:4 }}>Nothing here yet!</p>
                <p style={{ fontSize:13 }}>Tap the orange + to add a reminder</p>
              </div>
            )}

            {pending.map((t) => (
              <TaskCard key={t.id} task={t}
                onCheck={e => { e.stopPropagation(); toggle(t.id); }}
                onClick={() => { setSelectedId(t.id); setScreen("detail"); }}/>
            ))}

            {completed.length > 0 && (
              <>
                <div style={{ display:"flex", alignItems:"center", gap:8, margin:"16px 0 8px" }}>
                  <div style={{ flex:1, height:1.5, background:"#EEE5D8" }}/>
                  <span style={{ fontSize:11, color:"#CCC", fontWeight:800 }}>COMPLETED 🎉</span>
                  <div style={{ flex:1, height:1.5, background:"#EEE5D8" }}/>
                </div>
                {completed.map((t) => (
                  <TaskCard key={t.id} task={t} done
                    onCheck={e => { e.stopPropagation(); toggle(t.id); }}
                    onClick={() => { setSelectedId(t.id); setScreen("detail"); }}/>
                ))}
              </>
            )}
          </div>

          {/* FAB */}
          <button
            onClick={() => setScreen("add")}
            style={{
              position:"fixed", bottom:28, left:"50%", transform:"translateX(-50%)",
              width:66, height:66, borderRadius:"50%",
              background:"linear-gradient(145deg,#FF8C00,#FFAA30)",
              border:"none",
              boxShadow:"0 6px 22px rgba(255,140,0,0.5), 0 2px 6px rgba(0,0,0,0.1)",
              cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center",
              zIndex:99,
            }}>
            <svg width="30" height="30" viewBox="0 0 30 30" fill="none">
              <line x1="15" y1="5" x2="15" y2="25" stroke="white" strokeWidth="3.5" strokeLinecap="round"/>
              <line x1="5"  y1="15" x2="25" y2="15" stroke="white" strokeWidth="3.5" strokeLinecap="round"/>
            </svg>
          </button>
        </div>
      )}

      {/* ── ADD ── */}
      {screen === "add" && (
        <div style={{ position:"relative", zIndex:1, animation:"slideUp 0.35s ease", minHeight:"100vh", paddingBottom:40 }}>
          <div style={{
            background:"linear-gradient(135deg,#FFF9F2,#FFF3E0)",
            borderBottom:"2px solid #EDE5D8",
            padding:"20px 20px 16px",
            display:"flex", alignItems:"center", gap:12,
          }}>
            <button onClick={() => setScreen("home")} style={{
              background:"white", border:"2px solid #EEE8DE", borderRadius:12,
              padding:"6px 11px", fontSize:18, cursor:"pointer",
            }}>←</button>
            <div>
              <h2 style={{ fontFamily:"'Fredoka One'", fontSize:22, color:"#333" }}>New Reminder 🔔</h2>
              <p style={{ fontSize:11, color:"#B08860", fontWeight:700 }}>Fill in the boxes below</p>
            </div>
            <RocketSVG style={{ marginLeft:"auto", width:28, height:34, animation:"float 2s ease-in-out infinite" }}/>
          </div>

          <div style={{ padding:"20px 16px", display:"flex", flexDirection:"column", gap:14 }}>

            <Box label="✏️ Task Name">
              <input
                value={form.title}
                onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
                placeholder="e.g. Morning run, Read a book…"
                style={{
                  width:"100%", border:"none", background:"transparent",
                  fontSize:15, fontWeight:700, color:"#333", padding:"10px 0 4px",
                }}/>
            </Box>

            <Box label="⏰ Time">
              <input
                type="time"
                value={form.time}
                onChange={e => setForm(f => ({ ...f, time: e.target.value }))}
                style={{
                  width:"100%", border:"none", background:"transparent",
                  fontSize:22, fontWeight:900, color:"#FF8C00", padding:"8px 0 4px",
                }}/>
            </Box>

            <Box label="🏷️ Category">
              <div style={{ display:"flex", gap:8, flexWrap:"wrap", paddingTop:10 }}>
                {CATEGORIES.map((c,i) => (
                  <button key={i}
                    onClick={() => setForm(f => ({ ...f, category: i }))}
                    style={{
                      background: form.category===i ? c.color : "#F5F0EA",
                      border:`2px solid ${form.category===i ? c.color : "#EEE5D8"}`,
                      borderRadius:20, padding:"6px 13px",
                      fontSize:13, fontWeight:700, cursor:"pointer",
                      color: form.category===i ? "white" : "#888",
                      boxShadow: form.category===i ? `0 4px 12px ${c.color}66` : "none",
                      transition: "all 0.15s ease",
                    }}>{c.emoji} {c.label}</button>
                ))}
              </div>
            </Box>

            <Box label="⚡ Priority">
              <div style={{ display:"flex", gap:8, paddingTop:10 }}>
                {PRIORITIES.map((p,i) => (
                  <button key={i}
                    onClick={() => setForm(f => ({ ...f, priority: i }))}
                    style={{
                      flex: 1,
                      background: form.priority===i ? p.color : "#F5F0EA",
                      border:`2px solid ${form.priority===i ? p.color : "#EEE5D8"}`,
                      borderRadius:18, padding:"8px",
                      fontSize:13, fontWeight:800, cursor:"pointer",
                      color: form.priority===i ? (i === 1 ? "#665000" : "white") : "#888",
                      boxShadow: form.priority===i ? `0 4px 12px ${p.color}66` : "none",
                      transition: "all 0.15s ease",
                    }}>{p.icon} {p.label}</button>
                ))}
              </div>
            </Box>

            <Box label="🔁 Repeat">
              <div style={{ display:"flex", gap:6, overflowX:"auto", paddingTop:10, paddingBottom:2 }}>
                {REPEAT_OPTIONS.map((r) => (
                  <button key={r}
                    onClick={() => setForm(f => ({ ...f, repeat: r }))}
                    style={{
                      background: form.repeat===r ? "#FF8C00" : "#F5F0EA",
                      border:`2px solid ${form.repeat===r ? "#FF8C00" : "#EEE5D8"}`,
                      borderRadius:16, padding:"6px 12px",
                      fontSize:12, fontWeight:700, cursor:"pointer",
                      whiteSpace:"nowrap",
                      color: form.repeat===r ? "white" : "#888",
                    }}>{r}</button>
                ))}
              </div>
            </Box>

            <Box label="📝 Notes">
              <textarea
                value={form.note}
                onChange={e => setForm(f => ({ ...f, note: e.target.value }))}
                placeholder="Any details, locations, or descriptions..."
                rows={3}
                style={{
                  width:"100%", border:"none", background:"transparent", resize:"none",
                  fontSize:14, fontWeight:600, color:"#555", padding:"10px 0 2px",
                }}/>
            </Box>

            <button
              onClick={save}
              disabled={!form.title.trim() || !form.time}
              style={{
                background: (!form.title.trim() || !form.time) ? "#D8D0C5" : "linear-gradient(145deg,#FF8C00,#FFAA30)",
                color:"white", border:"none", borderRadius:22, padding:"16px",
                fontFamily:"'Fredoka One'", fontSize:18, letterSpacing:0.5,
                cursor: (!form.title.trim() || !form.time) ? "not-allowed" : "pointer",
                boxShadow: (!form.title.trim() || !form.time) ? "none" : "0 6px 20px rgba(255,140,0,0.4)",
                marginTop:10, transition:"all 0.2s",
              }}>
              Create Reminder 🚀
            </button>
          </div>

          {/* Success Overlay Popin */}
          {success && (
            <div style={{
              position:"fixed", inset:0, background:"rgba(248,245,240,0.92)",
              display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center",
              zIndex:999,
            }}>
              <div style={{
                background:"white", width:130, height:130, borderRadius:"50%",
                boxShadow:"0 8px 30px rgba(152,251,152,0.4)", border:"4px solid #98FB98",
                display:"flex", alignItems:"center", justifyContent:"center",
                fontSize:50, animation:"successPop 0.45s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards",
              }}>🎉</div>
              <p style={{ fontFamily:"'Fredoka One'", fontSize:22, color:"#333", marginTop:20, animation:"popIn 0.3s ease" }}>Added!</p>
            </div>
          )}
        </div>
      )}

      {/* ── DETAIL ── */}
      {screen === "detail" && selected && (
        <div style={{ position:"relative", zIndex:1, animation:"popIn 0.25s cubic-bezier(0.1, 0.8, 0.25, 1)", minHeight:"100vh" }}>
          <div style={{
            background:`linear-gradient(135deg, white, ${CATEGORIES[selected.category].color}22)`,
            borderBottom:"2px solid #EDE5D8",
            padding:"20px 20px 18px",
            display:"flex", alignItems:"center", gap:12,
          }}>
            <button onClick={() => setScreen("home")} style={{
              background:"white", border:"2px solid #EEE8DE", borderRadius:12,
              padding:"6px 11px", fontSize:18, cursor:"pointer",
            }}>←</button>
            <div>
              <h2 style={{ fontFamily:"'Fredoka One'", fontSize:20, color:"#333" }}>Details 👀</h2>
            </div>
          </div>

          <div style={{ padding:"24px 16px", display:"flex", flexDirection:"column", gap:16 }}>
            <div style={{
              background:"white", borderRadius:24, padding:22,
              boxShadow:"0 4px 20px rgba(0,0,0,0.04)", border:"2px solid #F0E8D8",
              position:"relative", overflow:"hidden"
            }}>
              <div style={{
                position:"absolute", top:-15, right:-15, width:90, height:90, borderRadius:"50%",
                background: CATEGORIES[selected.category].color + "18",
                display:"flex", alignItems:"center", justifyContent:"center", fontSize:36, paddingRight:10, paddingTop:10
              }}>
                {CATEGORIES[selected.category].emoji}
              </div>

              <div style={{
                display:"inline-block", background: PRIORITIES[selected.priority].color,
                color: selected.priority === 1 ? "#665000" : "white",
                fontSize:11, fontWeight:900, padding:"4px 10px", borderRadius:10, marginBottom:12,
                boxShadow: `0 2px 8px ${PRIORITIES[selected.priority].color}55`
              }}>
                {PRIORITIES[selected.priority].icon} {PRIORITIES[selected.priority].label} Priority
              </div>

              <h1 style={{ fontSize:22, fontWeight:800, color:"#333", marginBottom:14, lineHeight:1.3 }}>
                {selected.title}
              </h1>

              <div style={{ display:"flex", flexDirection:"column", gap:10, borderTop:"1.5px dashed #EEE5D8", paddingTop:14 }}>
                <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                  <span style={{ fontSize:18 }}>⏰</span>
                  <div>
                    <p style={{ fontSize:11, color:"#BBAA99", fontWeight:800 }}>TIME</p>
                    <p style={{ fontSize:16, fontWeight:800, color:"#FF8C00" }}>{selected.time}</p>
                  </div>
                </div>

                <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                  <span style={{ fontSize:18 }}>🔁</span>
                  <div>
                    <p style={{ fontSize:11, color:"#BBAA99", fontWeight:800 }}>REPEAT</p>
                    <p style={{ fontSize:14, fontWeight:700, color:"#555" }}>{selected.repeat}</p>
                  </div>
                </div>

                <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                  <span style={{ fontSize:18 }}>🏷️</span>
                  <div>
                    <p style={{ fontSize:11, color:"#BBAA99", fontWeight:800 }}>CATEGORY</p>
                    <p style={{ fontSize:14, fontWeight:700, color:"#555" }}>
                      {CATEGORIES[selected.category].emoji} {CATEGORIES[selected.category].label}
                    </p>
                  </div>
                </div>

                <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                  <span style={{ fontSize:18 }}>📌</span>
                  <div>
                    <p style={{ fontSize:11, color:"#BBAA99", fontWeight:800 }}>STATUS</p>
                    <p style={{ fontSize:14, fontWeight:800, color: selected.done ? "#5DBB63" : "#FF6B6B" }}>
                      {selected.done ? "Completed! ✨" : "Still Pending 💪"}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {selected.note && (
              <Box label="📝 Notes">
                <p style={{ fontSize:14, fontWeight:600, color:"#555", paddingTop:6, lineHeight:1.4, whiteSpace:"pre-wrap" }}>
                  {selected.note}
                </p>
              </Box>
            )}

            <div style={{ display:"flex", gap:10, marginTop:10 }}>
              <button
                onClick={() => { toggle(selected.id); setScreen("home"); }}
                style={{
                  flex:2,
                  background: selected.done ? "#F0EBE3" : "linear-gradient(145deg,#5DBB63,#7DD87E)",
                  color: selected.done ? "#777" : "white",
                  border: selected.done ? "2px solid #DDD" : "none",
                  borderRadius:20, padding:"14px",
                  fontFamily:"'Fredoka One'", fontSize:15, cursor:"pointer",
                  boxShadow: selected.done ? "none" : "0 4px 14px rgba(93,187,99,0.35)",
                }}>
                {selected.done ? "Undo Task ↩️" : "Mark Complete Done 🎉"}
              </button>

              <button
                onClick={() => remove(selected.id)}
                style={{
                  flex:1, background:"#FFF0F0", color:"#FF6B6B",
                  border:"2px solid #FFD0D0", borderRadius:20, padding:"14px",
                  fontFamily:"'Fredoka One'", fontSize:15, cursor:"pointer",
                }}>
                Delete 🗑️
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
