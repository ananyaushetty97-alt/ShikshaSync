import { useState, useEffect } from 'react'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'
import './styles.css'

// Mock data for demo - replace with real API calls
const mockStudents = [
  { id: 's1', name: 'Priya', grade: 6, language: 'kn', avatar: '👧', lastSync: '2026-11-24T10:30:00Z', mastery: { 'fractions-addition-same-denom': 0.32, 'fractions-subtraction': 0.65 } },
  { id: 's2', name: 'Arjun', grade: 6, language: 'kn', avatar: '👦', lastSync: '2026-11-24T10:35:00Z', mastery: { 'fractions-addition-same-denom': 0.82, 'fractions-subtraction': 0.78 } },
  { id: 's3', name: 'Meera', grade: 5, language: 'kn', avatar: '👧', lastSync: '2026-11-24T09:15:00Z', mastery: { 'fractions-addition-same-denom': 0.41, 'fractions-subtraction': 0.55 } },
  { id: 's4', name: 'Ravi', grade: 6, language: 'hi', avatar: '👦', lastSync: '2026-11-23T16:20:00Z', mastery: { 'fractions-addition-same-denom': 0.28, 'fractions-subtraction': 0.45 } },
  { id: 's5', name: 'Lakshmi', grade: 5, language: 'ta', avatar: '👧', lastSync: '2026-11-24T11:00:00Z', mastery: { 'fractions-addition-same-denom': 0.75, 'fractions-subtraction': 0.68 } },
  { id: 's6', name: 'Kiran', grade: 6, language: 'kn', avatar: '👦', lastSync: '2026-11-22T14:00:00Z', mastery: { 'fractions-addition-same-denom': 0.38, 'fractions-subtraction': 0.52 } },
]

const mockSkills = [
  { id: 'fractions-addition-same-denom', name: 'Adding fractions (same denominator)', subject: 'math' },
  { id: 'fractions-subtraction', name: 'Subtracting fractions', subject: 'math' },
  { id: 'multiplication-basics', name: 'Basic multiplication', subject: 'math' },
]

function App() {
  const [students, setStudents] = useState(mockStudents)
  const [selectedGrade, setSelectedGrade] = useState('all')
  const [selectedSkill, setSelectedSkill] = useState('all')
  const [loading, setLoading] = useState(false)

  // Compute skill-gap groups
  const skillGapGroups = () => {
    const groups = {}
    const filteredStudents = students.filter(s =>
      (selectedGrade === 'all' || s.grade === parseInt(selectedGrade)) &&
      (selectedSkill === 'all' || s.mastery[selectedSkill] !== undefined)
    )

    filteredStudents.forEach(student => {
      Object.entries(student.mastery).forEach(([skillId, mastery]) => {
        if (mastery < 0.5) { // Struggling threshold
          if (!groups[skillId]) groups[skillId] = { skillId, students: [] }
          groups[skillId].students.push({ ...student, mastery })
        }
      })
    })

    return Object.values(groups)
      .map(g => ({ ...g, count: g.students.length }))
      .sort((a, b) => b.count - a.count)
  }

  const groups = skillGapGroups()

  // Sync status stats
  const now = new Date()
  const syncedCount = students.filter(s => {
    const lastSync = new Date(s.lastSync)
    return (now - lastSync) / (1000 * 60 * 60) < 24 // synced within 24h
  }).length
  const pendingCount = students.length - syncedCount
  const offlineCount = students.filter(s => {
    const lastSync = new Date(s.lastSync)
    return (now - lastSync) / (1000 * 60 * 60 * 24) > 7 // not synced in 7 days
  }).length

  const getSyncStatus = (lastSyncStr) => {
    const lastSync = new Date(lastSyncStr)
    const hoursAgo = (now - lastSync) / (1000 * 60 * 60)
    if (hoursAgo < 24) return { label: 'Synced', class: 'synced' }
    if (hoursAgo < 168) return { label: 'Pending', class: 'pending' }
    return { label: 'Offline', class: 'offline' }
  }

  const getMasteryClass = (mastery) => {
    if (mastery >= 0.8) return 'high'
    if (mastery >= 0.5) return 'medium'
    return 'low'
  }

  const getMasteryLabel = (mastery) => {
    if (mastery >= 0.8) return 'Mastered'
    if (mastery >= 0.5) return 'Learning'
    return 'Needs Help'
  }

  return (
    <div className="dashboard">
      <header className="header">
        <h1>ShikshaSync Teacher Dashboard</h1>
        <div style={{ display: 'flex', gap: 16, alignItems: 'center', fontSize: '14px', color: '#64748b' }}>
          <span>🏫 RV College of Engineering</span>
          <span>Track: UnlockED</span>
        </div>
      </header>

      <main className="main">
        {/* Filters */}
        <div className="filters">
          <div className="filter-group">
            <label>Grade</label>
            <select value={selectedGrade} onChange={e => setSelectedGrade(e.target.value)}>
              <option value="all">All Grades</option>
              <option value="5">Grade 5</option>
              <option value="6">Grade 6</option>
              <option value="7">Grade 7</option>
              <option value="8">Grade 8</option>
            </select>
          </div>
          <div className="filter-group">
            <label>Skill</label>
            <select value={selectedSkill} onChange={e => setSelectedSkill(e.target.value)}>
              <option value="all">All Skills</option>
              {mockSkills.map(skill => (
                <option key={skill.id} value={skill.id}>{skill.name}</option>
              ))}
            </select>
          </div>
          <button
            onClick={() => { setLoading(true); setTimeout(() => setLoading(false), 1000) }}
            disabled={loading}
            style={{
              padding: '8px 16px',
              background: '#2E7D32',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              fontWeight: 500,
              cursor: loading ? 'not-allowed' : 'pointer',
              opacity: loading ? 0.7 : 1,
              marginTop: 'auto'
            }}
          >
            {loading ? '🔄 Refreshing...' : '🔄 Refresh Data'}
          </button>
        </div>

        {/* Sync Status Overview */}
        <div className="grid">
          <div className="card">
            <h2>📊 Sync Status</h2>
            <div className="sync-status">
              <div className="sync-overview">
                <div className="sync-stat">
                  <div className="sync-stat-value">{syncedCount}</div>
                  <div className="sync-stat-label">Synced (24h)</div>
                </div>
                <div className="sync-stat">
                  <div className="sync-stat-value warning">{pendingCount}</div>
                  <div className="sync-stat-label">Pending Sync</div>
                </div>
                <div className="sync-stat">
                  <div className="sync-stat-value danger">{offlineCount}</div>
                  <div className="sync-stat-label">Offline > 7 days</div>
                </div>
              </div>
            </div>
          </div>

          {/* Skill Gap Groups */}
          <div className="card" style={{ gridColumn: 'span 2' }}>
            <h2>🎯 Students Needing Help (by Skill Gap)</h2>
            {groups.length === 0 ? (
              <div className="empty-state">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
                <p>All students are on track! 🎉</p>
              </div>
            ) : (
              <div className="skill-gap-list">
                {groups.map(group => {
                  const skill = mockSkills.find(s => s.id === group.skillId)
                  return (
                    <div key={group.skillId} className="skill-gap-card">
                      <div className="skill-gap-header">
                        <div>
                          <div className="skill-gap-title">{skill?.name || group.skillId}</div>
                          <div style={{ fontSize: '13px', color: '#92400e', marginTop: '4px' }}>
                            {group.students.filter(s => s.mastery < 0.4).length} need revision • {group.students.filter(s => s.mastery >= 0.4 && s.mastery < 0.5).length} need practice
                          </div>
                        </div>
                        <span className="skill-gap-count">{group.count} students</span>
                      </div>
                      <div className="skill-gap-students">
                        {group.students.map(student => (
                          <span key={student.id} className={`student-tag ${student.mastery < 0.4 ? 'struggling' : ''}`}>
                            {student.avatar} {student.name} ({Math.round(student.mastery * 100)}%)
                          </span>
                        ))}
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        </div>

        {/* Student List & Activity Suggestions */}
        <div className="grid">
          {/* Student Progress Table */}
          <div className="card" style={{ gridColumn: 'span 2' }}>
            <h2>👥 Student Progress</h2>
            <div style={{ overflowX: 'auto' }}>
              <table className="student-table">
                <thead>
                  <tr>
                    <th>Student</th>
                    <th>Grade</th>
                    <th>Language</th>
                    <th>Last Sync</th>
                    <th>Status</th>
                    {mockSkills.map(skill => (
                      <th key={skill.id}>{skill.name}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {students
                    .filter(s => selectedGrade === 'all' || s.grade === parseInt(selectedGrade))
                    .map(student => {
                      const syncStatus = getSyncStatus(student.lastSync)
                      return (
                        <tr key={student.id}>
                          <td>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                              <span style={{ fontSize: '20px' }}>{student.avatar}</span>
                              <span style={{ fontWeight: 500 }}>{student.name}</span>
                            </div>
                          </td>
                          <td>Grade {student.grade}</td>
                          <td>{student.language.toUpperCase()}</td>
                          <td>{new Date(student.lastSync).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' })}</td>
                          <td><span className={`status-badge ${syncStatus.class}`}>{syncStatus.label}</span></td>
                          {mockSkills.map(skill => {
                            const mastery = student.mastery[skill.id] || 0
                            const masteryClass = getMasteryClass(mastery)
                            return (
                              <td key={skill.id}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                                  <div className="mastery-bar" style={{ width: '80px' }}>
                                    <div className={`mastery-fill ${masteryClass}`} style={{ width: `${mastery * 100}%` }} />
                                  </div>
                                  <span style={{ fontSize: '12px', fontWeight: 500, color: masteryClass === 'high' ? '#166534' : masteryClass === 'medium' ? '#92400e' : '#991b1b' }}>
                                    {Math.round(mastery * 100)}%
                                  </span>
                                </div>
                              </td>
                            )
                          })}
                        </tr>
                      )
                    })}
                </tbody>
              </table>
            </div>
          </div>

          {/* Activity Suggestions */}
          <div className="card">
            <h2>💡 Suggested Activities</h2>
            {groups.length === 0 ? (
              <div className="empty-state">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p>No interventions needed today</p>
              </div>
            ) : (
              <div>
                {groups.slice(0, 3).map((group, idx) => {
                  const skill = mockSkills.find(s => s.id === group.skillId)
                  const strugglingCount = group.students.filter(s => s.mastery < 0.4).length
                  const practiceCount = group.students.filter(s => s.mastery >= 0.4 && s.mastery < 0.5).length

                  let activityTitle, activityDesc
                  if (strugglingCount > 0) {
                    activityTitle = `🔴 Revision: ${skill?.name || group.skillId}`
                    activityDesc = `${strugglingCount} student(s) need foundational revision. Use visual aids and hands-on activity (10 min).`
                  } else {
                    activityTitle = `🟡 Practice: ${skill?.name || group.skillId}`
                    activityDesc = `${practiceCount} student(s) need guided practice. Pair them for peer learning (10 min).`
                  }

                  return (
                    <div key={group.skillId} className="activity-card">
                      <div className="activity-title">{activityTitle}</div>
                      <div className="activity-description">{activityDesc}</div>
                      <button className="activity-action">Start Activity</button>
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        </div>

        {/* Mastery Distribution Chart */}
        <div className="grid">
          <div className="card" style={{ gridColumn: '1 / -1' }}>
            <h2>📈 Class Mastery Distribution</h2>
            <div style={{ height: 300 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={mockSkills.map(skill => {
                  const masteries = students.map(s => s.mastery[skill.id] || 0).filter(m => m > 0)
                  const avg = masteries.length ? masteries.reduce((a, b) => a + b, 0) / masteries.length : 0
                  const mastered = masteries.filter(m => m >= 0.8).length
                  const learning = masteries.filter(m => m >= 0.5 && m < 0.8).length
                  const struggling = masteries.filter(m => m < 0.5).length
                  return {
                    name: skill.name.length > 20 ? skill.name.slice(0, 20) + '...' : skill.name,
                    average: Math.round(avg * 100),
                    mastered,
                    learning,
                    struggling,
                  }
                })}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="name" stroke="#64748b" fontSize={12} />
                  <YAxis stroke="#64748b" fontSize={12} domain={[0, 'auto']} />
                  <Tooltip
                    formatter={(value, name) => [value, name]}
                    labelFormatter={(label) => `Skill: ${label}`}
                  />
                  <Bar dataKey="mastered" name="Mastered (≥80%)" fill="#22c55e" radius={[4, 4, 0, 0]} />
                  <Bar dataKey="learning" name="Learning (50-79%)" fill="#f59e0b" radius={[4, 4, 0, 0]} />
                  <Bar dataKey="struggling" name="Needs Help (<50%)" fill="#ef4444" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}

export default App