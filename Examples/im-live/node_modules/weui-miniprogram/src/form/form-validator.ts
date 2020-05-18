import Validator from './validator'
import {diff} from '../utils/object'

const toString = Object.prototype.toString
const validateSingleRule = (rule: any, value:any, param:any = null, models = null) => {
    let message = ''
    for (const ruleKey in rule) {
        if (ruleKey === 'name' || ruleKey === 'message') continue
        const validateMethod = typeof rule.validator !== 'undefined' ? rule.validator : Validator[ruleKey]
        if (typeof validateMethod === 'function') {
            message = validateMethod(rule, value, param, models)
            if (message) {
                return message
            }
        }

    }
    return message
}
class FormValidator {
    models: {}
    rules: {}
    errors: {}
    constructor(models, rules) {
        this.models = models
        this.rules = rules
        this.errors = {}
    }
    validate(cb) {
        return new Promise((resolve) => {
            let fieldCount = 0
            let failCount = 0
            const errors = this.errors
            const models = this.models
            let errorChanged = false
            for (const k in this.rules) {
                ((fieldName) => {
                    const oldError = errors[fieldName]
                    this._innerValidateField(k, models[fieldName], (valid, newError) => {
                        fieldCount++
                        if (!valid) failCount++
                        if (diff(oldError, newError)) {
                            errors[fieldName] = newError
                            errorChanged = true
                        }
                    })
                })(k)
            }
            // this.page.setData(this.errorsKey, this.errors)
            if (errorChanged) {
                // 触发一个errorchange事件
                // this.triggerEvent('errorchange', errors || {})
            }
            const keys = Object.keys(errors)
            keys.forEach(key => {
                if (!errors[key])
                    delete errors[key]
            })
            // 先支持同步的接口吧
            resolve({isValid: !failCount, errors: failCount ? errors : undefined})
            cb && cb(!failCount, failCount ? errors : undefined)
        })
    }
    validateField(name, value, cb = (v, error = null) => {}) {
        return new Promise(resolve => {
            this._innerValidateField(name, value, (valid, error) => {
                // this.page.setData(this.errorsKey, this.errors)
                const errObj = {}
                errObj[name] = error
                resolve({valid, error: valid ? undefined : error})
                cb(valid, valid ? undefined : errObj)
                const oldError = this.errors[name]
                const errorChanged = diff(oldError, error)
                // 触发一个errorchange事件
                if (errorChanged) {
                    if (!error) delete this.errors[name]
                    this.errors[name] = error
                    // this.triggerEvent('errorchange', this.errors)
                }
            })

        })
    }
    _innerValidateField(name, value, cb = (v, errors=null) => {}) {
        const rules = this.rules[name]
        if (!rules) {
            console.warn(`[form-validtor] rule name ${name} not exists.`)
            cb(true)
            return
        }
        // 处理参数
        if (typeof value === 'function') {
            cb = value
            value = undefined
        }
        let isFail = false
        const models = this.models
        if (toString.call(rules) === '[object Array]') {
            rules.forEach(rule => {
                rule.name = name // 字段名称
                const resMessage = validateSingleRule(rule, value || models[name], rule.param, models)
                // 失败了直接中止
                if (resMessage && !isFail) {
                    isFail = true
                    // errors[name] = {message: resMessage}
                    const error = resMessage ? {message: resMessage, rule} : undefined
                    cb(false, error)
                }
            })
            // 成功的回调
            if (!isFail) {
                cb(!isFail)
            }
        } else {
            const rule = rules
            rule.name = name
            const resMessage = validateSingleRule(rule, value || models[name], rule.param, models)
            const error = resMessage ? {message: resMessage, rule} : undefined
            if (resMessage) {
                isFail = true
            }
            cb(!isFail, error)
        }
    }
    addMethod(ruleName, method) {
        Validator[ruleName] = method
    }
    setModel(newModel) {
        this.models = newModel
    }
    setRules(newRules) {
        this.rules = newRules
    }
}
export default FormValidator
