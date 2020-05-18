import FormValidator from './form-validator'
import {diffObject} from '../utils/object'

function linked(target) {
    if (target.data.prop) {
        this.data.formItems[target.data.prop] = target
    }
    if (target.setInForm) {
        target.setInForm()
    }
    if (!this.data.firstItem) {
        this.data.firstItem = target
    }
    if (target !== this.data.firstItem) {
        // target.setOuterClass('weui-cell_wxss')
    }
}
function unlinked(target) {
    if (target.data.prop) {
        delete this.data.formItems[target.data.prop]
    }
}

Component({
    properties: {
        models: {
            type: Object,
            value: {},
            observer: '_modelChange'
        },
        rules: { // 格式是[{name, rules: {}}]
            type: Array,
            value: [],
            observer: '_rulesChange'
        },
        extClass: {
            type: String,
            value: ''
        }
    },
    data: {
        errors: {},
        formItems: {},
        firstItem: null
    },
    relations: {
        '../cell/cell': {
            type: 'descendant',
            linked: linked,
            unlinked
        },
        '../checkbox-group/checkbox-group': {
            type: 'descendant',
            linked: linked,
            unlinked
        }
    },
    attached() {
        this.initRules()
        this.formValidator = new FormValidator(this.data.models, this.data.newRules)
    },
    methods: {
        initRules(rules) {
            const newRules = {};
            (rules || this.data.rules).forEach(rule => {
                if (rule.name && rule.rules) {
                    newRules[rule.name] = rule.rules || []
                }
            })
            this.setData({newRules})
            return newRules
        },
        _modelChange(newVal, oldVal, path) {
            if (!this.isInit) {
                this.isInit = true
                return newVal
            }
            // 这个必须在前面
            this.formValidator.setModel(newVal)
            this.isInit = true
            const diffObj: any = diffObject(oldVal, newVal)
            if (diffObj) {
                let isValid = true
                const errors = []
                const errorMap = {}
                for (const k in diffObj) {
                    this.formValidator.validateField(k, diffObj[k], function(isValided, error) {
                        if (error && error[k]) {
                            errors.push(error[k])
                            errorMap[k] = error[k]
                        }
                        isValid = isValided
                    })
                }
                this._showErrors(diffObj, errorMap)
                this.triggerEvent(isValid ? 'success' : 'fail', isValid ? {trigger: 'change'} : {errors, trigger: 'change'})
            }
            return newVal
        },
        _rulesChange(newVal) {
            const newRules = this.initRules(newVal)
            if (this.formValidator) {
                this.formValidator.setRules(newRules)
            }
            return newVal
        },
        _showAllErrors(errors) {
            for (const k in this.data.newRules) {
                this._showError(k, errors && errors[k])
            }
        },
        _showErrors(objs, errors) {
            for (const k in objs) {
                this._showError(k, errors && errors[k])
            }

        },
        _showError(prop, error) {
            const formItem = this.data.formItems[prop]
            if (formItem && formItem.data.showError) {
                formItem.setError(error)
            }
        },
        validate(cb) {
            return this.formValidator.validate((isValid, errors) => {
                this._showAllErrors(errors)
                const handleError = this.handleErrors(errors)
                this.triggerEvent(isValid ? 'success' : 'fail', isValid ? {trigger: 'validate'} : {errors: handleError, trigger: 'validate'})
                cb && cb(isValid, handleError)
            })
        },
        validateField(name, value, cb = (v, error = null) => {}) {
            return this.formValidator.validateField(name, value, (isValid, errors) => {
                this._showError(name, errors)
                const handleError = this.handleErrors(errors)
                this.triggerEvent(isValid ? 'success' : 'fail', isValid ? {trigger: 'validate'} : {errors: handleError, trigger: 'validate'})
                cb && cb(isValid, handleError)
            })
        },
        handleErrors(errors) {
            if (errors) {
                const newErrors = []
                this.data.rules.forEach(rule => {
                    if (errors[rule.name]) {
                        errors[rule.name].name = rule.name
                        newErrors.push(errors[rule.name])
                    }
                })
                return newErrors
            }
            return errors
        },
        addMethod(ruleName, method) {
            return this.formValidator.addMethod(ruleName, method)
        }
    }
})
export default FormValidator
