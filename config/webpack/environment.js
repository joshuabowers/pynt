const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const merge = require('webpack-merge')

// Enable CSS Modules
const cssLoaderOptions = {
  modules: true,
  sourceMap: true,
  localIdentName: '[name]__[local]__[hash:base64:5]'
}

const CSSLoader = environment.loaders.get('sass').use.find( el => el.loader === 'css-loader')

CSSLoader.options = merge(CSSLoader.options, cssLoaderOptions)

// Add ActionCable as a plugin
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    ActionCable: 'actioncable'
  })
)

module.exports = environment
