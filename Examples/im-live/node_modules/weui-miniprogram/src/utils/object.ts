export const diff = (old, newVal) => {
    if ((!old && newVal) || (old && !newVal)) return true
    for (const k in newVal) {
        if (old[k] !== newVal[k]) return true
    }
    for (const k in old) {
        if (old[k] !== newVal[k]) return true
    }
    return false
}
export const diffObject = (old, newVal) => {
    if (!old && newVal) return newVal
    if (!newVal && old) return old
    const diffObj = {}
    let isDiff = false
    for (const k in newVal) {
        if (old[k] !== newVal[k]) {
            isDiff = true
            diffObj[k] = newVal[k]
        }
    }
    for (const k in old) {
        if (old[k] !== newVal[k]) {
            isDiff = true
            diffObj[k] = newVal[k]
        }
    }
    return isDiff ? diffObj : null
}