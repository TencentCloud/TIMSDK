const ModuleScopePlugin = require('react-dev-utils/ModuleScopePlugin');

module.exports = function override(config, env) {
    config.resolve.plugins = config.resolve.plugins.filter(plugin => !(plugin instanceof ModuleScopePlugin));
    const overrideConfig = {
        ...config,
        target: 'electron-renderer',
        node: {
            global: true,
            __dirname: true,
            __filename: true
        }
    }

    return overrideConfig
}