module.exports = {
  "filenameHashing": false,
  "publicPath": "/resources/js-ui/",
  "outputDir": "../WebContent/resources/js-ui/",
  "configureWebpack": {
    "devtool": "source-map"
  },

  "transpileDependencies": [
    "vuetify"
  ],

  pluginOptions: {
    i18n: {
      locale: 'en',
      fallbackLocale: 'en',
      localeDir: 'locales',
      enableInSFC: false
    }
  }
}
