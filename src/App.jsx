import React, { useState, useEffect } from 'react';

// Setup styling assets and configurations
const CATEGORIES = [
  { label: "Work",  emoji: "💼" },
  { label: "Study", emoji: "📚" },
  { label: "Health",emoji: "🍎" },
  { label: "Chore", emoji: "🧹" },
  { label: "Social",emoji: "🎉" }
];

const PRIORITIES = [
  { label: "Low",    icon: "🌱", color: "#A8E6CF" },
  { label: "Medium", icon: "🔥", color: "#FFD3B6" },
  { label: "High",   icon: "🚨", color: "#FF8B94" }
];

const REPEAT_OPTIONS = ["Never", "Daily", "Weekly", "Monthly"];

// Reusable custom input container box component
const Box = ({ label, children }) => (
  <div style={{ background: "white", padding: "14px 18px", borderRadius: 24, boxShadow: "0 8px 24px rgba(45,42,38,0.02)", border: "1px solid #EFECE6" }}>
    <span style={{ fontSize: 11, fontWeight: 900, color: "#A69A85", display: "block", textTransform: "uppercase", marginBottom: 8, letterSpacing: 0.5 }}>{label}</span>
    {children}
  </div>
);

export default function App() {
  // Application base states
  const [tasks,       setTasks]       = useState(() => JSON.parse(localStorage.getItem("oneup_tasks")) || []);
  const [screen,      setScreen]      = useState("home"); // home, add, detail
  const [filterCat,   setFilterCat]   = useState(null);
  const [selectedId,  setSelectedId]  = useState(null);
  const [success,     setSuccess]     = useState(false);

  // Initialize our audio effects (using clean, short public audio URLs)
  const taskAddedSound = new Audio("https://assets.mixkit.co/active_storage/sfx/2571/2571-84.wav"); // short pop/click
  const taskDoneSound  = new Audio("https://assets.mixkit.co/active_storage/sfx/1435/1435-84.wav"); // magical chime/success
  const reminderSound  = new Audio("https://assets.mixkit.co/active_storage/sfx/911/911-84.wav");   // polite digital double beep

  // Track which task times we have already reminded the user about during this session
  const [firedReminders, setFiredReminders] = useState({});

  const [form, setForm] = useState({ title: "", time: "", category: 0, priority: 1, repeat: "Never", note: "" });

  // 1. This automatically saves your tasks to storage every time they change
  useEffect(() => {
    localStorage.setItem("oneup_tasks", JSON.stringify(tasks));
  }, [tasks]);

  // 2. Automatically plays a reminder sound when a task time arrives
  useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date();
      const hrs = String(now.getHours()).padStart(2, '0');
      const mins = String(now.getMinutes()).padStart(2, '0');
      const currentTimeString = `${hrs}:${mins}`;

      tasks.forEach(task => {
        if (!task.done && task.time === currentTimeString && !firedReminders[task.id]) {
          reminderSound.play().catch(e => console.log("Audio play blocked by browser:", e));
          setFiredReminders(prev => ({ ...prev, [task.id]: true }));
        }
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [tasks, firedReminders]);

  const now = new Date();
  const dateStr = now.toLocaleDateString("en-US", { weekday: "long", month: "long", day: "numeric" });
  const doneCount = tasks.filter(t => t.done).length;
  const progress = tasks.length ? Math.round((doneCount / tasks.length) * 100) : 0;
  const filtered = filterCat === null ? tasks : tasks.filter(t => Number(t.category) === filterCat);

  const save = () => {
    if (!form.title.trim() || !form.time) return;
    
    if (selectedId) {
      setTasks(p => p.map(t => t.id === selectedId ? { ...form, id: selectedId } : t));
    } else {
      setTasks(p => [...p, { ...form, id: Date.now(), done: false }]);
      taskAddedSound.play().catch(e => {});
    }

    setForm({ title: "", time: "", category: 0, priority: 1, repeat: "Never", note: "" });
    setSuccess(true);
    setTimeout(() => { setSuccess(false); setScreen("home"); }, 950);
  };

  const toggle = id => {
    setTasks(p => p.map(t => {
      if (t.id === id) {
        if (!t.done) {
          taskDoneSound.play().catch(e => {});
        }
        return { ...t, done: !t.done };
      }
      return t;
    }));
  };

  const remove = id => { 
    setTasks(p => p.filter(t => t.id !== id)); 
    setScreen("home"); 
  };

  return (
    <div style={{
      minHeight: "100vh", background: "#F8F5F0",
      fontFamily: "'Nunito', sans-serif",
      maxWidth: 430, margin: "0 auto",
      position: "relative", overflowX: "hidden"
    }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Fredoka+One&display=swap');
        body { margin:0; padding:0; background:#1E1E24; }
        ::-webkit-scrollbar { display: none; }
        .no-select { -webkit-tap-highlight-color: transparent; }
        @keyframes pop { 0% { transform: scale(0.9); } 100% { transform: scale(1); } }
      `}</style>

      {/* Decorative background dots */}
      <div style={{ position:"absolute", top:0, left:0, right:0, bottom:0, pointerEvents:"none", opacity:0.4, backgroundImage:"radial-gradient(#DDD4C4 1.5px, transparent 1.5px)", backgroundSize:"24px 24px" }} />

      {screen === "home" && (
        <div style={{ padding: "24px 20px 100px", position:"relative", animation:"pop 0.2s ease-out" }}>
          <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom: 28 }}>
            <div>
              <p style={{ margin:0, fontSize:14, fontWeight:800, color:"#A69A85", textTransform:"uppercase", letterSpacing:0.5 }}>{dateStr}</p>
              <h1 style={{ fontFamily:"'Fredoka One'", margin:"4px 0 0", fontSize:32, color:"#2D2A26", letterSpacing:-0.5 }}>1UP Tasks</h1>
            </div>
            <div style={{ background:"white", padding:"10px 16px", borderRadius:20, boxShadow:"0 8px 20px rgba(0,0,0,0.04)", textAlign:"right", border:"1px solid #EFECE6" }}>
              <span style={{ fontSize:11, fontWeight:900, color:"#A69A85", display:"block", textTransform:"uppercase" }}>Level Progress</span>
              <span style={{ fontFamily:"'Fredoka One'", fontSize:20, color:"#FFB347" }}>{progress}%</span>
            </div>
          </div>

          {/* Quick Filter Row */}
          <div style={{ display:"flex", gap:8, overflowX:"auto", paddingBottom:12, marginBottom:16 }} className="no-select">
            <button onClick={() => setFilterCat(null)} style={{ background: filterCat===null?"#2D2A26":"white", color: filterCat===null?"white":"#2D2A26", border:"1px solid #EFECE6", padding:"8px 16px", borderRadius:16, fontWeight:800, fontSize:13, cursor:"pointer", whiteSpace:"nowrap" }}>All</button>
            {CATEGORIES.map((c, idx) => (
              <button key={idx} onClick={() => setFilterCat(idx)} style={{ background: filterCat===idx?"#2D2A26":"white", color: filterCat===idx?"white":"#2D2A26", border:"1px solid #EFECE6", padding:"8px 16px", borderRadius:16, fontWeight:800, fontSize:13, cursor:"pointer", whiteSpace:"nowrap", display:"flex", alignItems:"center", gap:6 }}>
                <span>{c.emoji}</span> {c.label}
              </button>
            ))}
          </div>

          {/* Task List */}
          {filtered.length === 0 ? (
            <div style={{ textAlign:"center", padding:"60px 20px", color:"#A69A85" }}>
              <span style={{ fontSize:40 }}>🍃</span>
              <p style={{ fontWeight:700, margin:"12px 0 4px", color:"#60584E" }}>All clear!</p>
              <p style={{ fontSize:13, margin:0, opacity:0.8 }}>No pending tasks in this category.</p>
            </div>
          ) : (
            <div style={{ display:"flex", flexDirection:"column", gap:12 }}>
              {filtered.map(t => (
                <div key={t.id} style={{ background:"white", borderRadius:24, padding:16, display:"flex", alignItems:"flex-start", gap:14, boxShadow:"0 10px 25px rgba(45,42,38,0.03)", border:"1px solid #EFECE6", opacity: t.done ? 0.6 : 1, transition:"all 0.2s" }}>
                  <button onClick={() => toggle(t.id)} style={{ background: t.done ? PRIORITIES[t.priority].color : "transparent", border:`3px solid ${PRIORITIES[t.priority].color}`, width:26, height:26, borderRadius:9, cursor:"pointer", marginTop:2, display:"flex", alignItems:"center", justifyContent:"center", padding:0, flexShrink:0 }}>
                    {t.done && <span style={{ color:"white", fontSize:14, fontWeight:900 }}>✓</span>}
                  </button>
                  <div style={{ flex:1, cursor:"pointer" }} onClick={() => { setSelectedId(t.id); setForm(t); setScreen("detail"); }}>
                    <h3 style={{ margin:0, fontSize:16, fontWeight:800, color:"#2D2A26", textDecoration: t.done?"line-through":"none" }}>{t.title}</h3>
                    <div style={{ display:"flex", gap:10, alignItems:"center", marginTop:6 }}>
                      <span style={{ fontSize:12, fontWeight:800, color:"#60584E", background:"#F1EDE4", padding:"3px 8px", borderRadius:8 }}>⏰ {t.time}</span>
                      <span style={{ fontSize:12, fontWeight:700, color:"#A69A85" }}>{CATEGORIES[t.category].emoji} {CATEGORIES[t.category].label}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Floating Action Button */}
          <button onClick={() => { setSelectedId(null); setForm({ title:"", time:"", category:0, priority:1, repeat:"Never", note:"" }); setScreen("add"); }} style={{ position:"fixed", bottom:24, left:"50%", transform:"translateX(-50%)", background:"#FF6B6B", color:"white", border:"none", width:140, height:52, borderRadius:26, fontSize:16, fontWeight:800, cursor:"pointer", boxShadow:"0 12px 30px rgba(255,107,107,0.4)", display:"flex", alignItems:"center", justifyContent:"center", gap:8 }} className="no-select">
            <span style={{ fontSize:20, marginTop:-2 }}>+</span> Add Task
          </button>
        </div>
      )}

      {(screen === "add" || screen === "detail") && (
        <div style={{ padding: "24px 20px 40px", animation:"pop 0.15s ease-out" }}>
          <div style={{ display:"flex", alignItems:"center", justifyValue:"space-between", justifyContent:"space-between", marginBottom:24 }}>
            <button onClick={() => setScreen("home")} style={{ background:"transparent", border:"none", fontSize:24, cursor:"pointer", color:"#2D2A26", padding:0 }}>←</button>
            <h2 style={{ fontFamily:"'Fredoka One'", margin:0, fontSize:22, color:"#2D2A26" }}>{screen === "add" ? "Create Task" : "Task Details"}</h2>
            <div style={{ width:24 }} />
          </div>

          <div style={{ display:"flex", flexDirection:"column", gap:20 }}>
            <Box label="Task Name">
              <input type="text" value={form.title} onChange={e => setForm({...form, title: e.target.value})} placeholder="What are you working on?" style={{ width:"100%", border:"none", background:"transparent", outline:"none", fontSize:16, fontWeight:700, color:"#2D2A26", padding:0 }} />
            </Box>

            <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:14 }}>
              <Box label="Target Time">
                <input type="time" value={form.time} onChange={e => setForm({...form, time: e.target.value})} style={{ width:"100%", border:"none", background:"transparent", outline:"none", fontSize:16, fontWeight:800, color:"#2D2A26", padding:0, cursor:"pointer" }} />
              </Box>
              <Box label="Repeat Cycle">
                <select value={form.repeat} onChange={e => setForm({...form, repeat: e.target.value})} style={{ width:"100%", border:"none", background:"transparent", outline:"none", fontSize:14, fontWeight:800, color:"#2D2A26", padding:0, cursor:"pointer" }}>
                  {REPEAT_OPTIONS.map((o,i) => <option key={i} value={o}>{o}</option>)}
                </select>
              </Box>
            </div>

            <Box label="Category Tag">
              <div style={{ display:"grid", gridTemplateColumns:"repeat(3, 1fr)", gap:8 }} className="no-select">
                {CATEGORIES.map((c, idx) => (
                  <button key={idx} onClick={() => setForm({...form, category: idx})} style={{ background: form.category === idx ? "#2D2A26" : "#F8F5F0", color: form.category === idx ? "white" : "#2D2A26", border:"none", padding:"12px 8px", borderRadius:16, fontSize:12, fontWeight:800, cursor:"pointer", display:"flex", flexDirection:"column", alignItems:"center", gap:4 }}>
                    <span style={{ fontSize:18 }}>{c.emoji}</span> {c.label}
                  </button>
                ))}
              </div>
            </Box>

            <Box label="Priority Burn Level">
              <div style={{ display:"grid", gridTemplateColumns:"repeat(3, 1fr)", gap:8 }} className="no-select">
                {PRIORITIES.map((p, idx) => (
                  <button key={idx} onClick={() => setForm({...form, priority: idx})} style={{ background: form.priority === idx ? p.color : "#F8F5F0", color: form.priority === idx ? "white" : "#2D2A26", border:"none", padding:"12px 8px", borderRadius:16, fontSize:13, fontWeight:800, cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center", gap:6 }}>
                    <span>{p.icon}</span> {p.label}
                  </button>
                ))}
              </div>
            </Box>

            <Box label="Additional Notes">
              <textarea value={form.note} onChange={e => setForm({...form, note: e.target.value})} placeholder="Add details or context..." rows={3} style={{ width:"100%", border:"none", background:"transparent", outline:"none", fontSize:14, fontWeight:700, color:"#2D2A26", padding:0, resize:"none" }} />
            </Box>

            <div style={{ marginTop: 10, display:"flex", flexDirection:"column", gap:12 }} className="no-select">
              <button onClick={save} style={{ width:"100%", background:"#4CAF50", color:"white", border:"none", padding:"16px", borderRadius:20, fontSize:16, fontWeight:800, cursor:"pointer", boxShadow:"0 8px 20px rgba(76,175,80,0.3)" }}>
                {screen === "add" ? "Launch Task 🚀" : "Update Records"}
              </button>
              
              {screen === "detail" && (
                <button onClick={() => remove(selectedId)} style={{ width:"100%", background:"transparent", color:"#FF6B6B", border:"2px solid #FF6B6B", padding:"14px", borderRadius:20, fontSize:15, fontWeight:800, cursor:"pointer" }}>
                  Terminate Task Data
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Action Complete Flash Animation */}
      {success && (
        <div style={{ position:"fixed", top:0, left:0, right:0, bottom:0, background:"rgba(255,255,255,0.9)", zIndex:9999, display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center", animation:"pop 0.15s ease-out" }}>
          <span style={{ fontSize:56 }}>⚡</span>
          <h2 style={{ fontFamily:"'Fredoka One'", color:"#2D2A26", margin:"12px 0 0" }}>Records Updated!</h2>
        </div>
      )}
    </div>
  );
}
