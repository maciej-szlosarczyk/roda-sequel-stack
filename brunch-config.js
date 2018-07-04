// See http://brunch.io for documentation.
exports.config = {
  files: {
    javascripts: {
      joinTo: {
        'assets/js/app.js': /^assets/,
        'assets/js/vendor.js': /^(?!assets)/ // We could also use /node_modules/ regex.
      }
    },
    stylesheets: {
      joinTo: 'assets/css/app.css'
    }
  },

  conventions: {
    assets: /^(static)/
  },

  paths: {
    watched: ['assets'],
    public: "public"
  },

  plugins: {
    sass: {
      mode: 'native',
      options: {
        includePaths: ["node_modules/bulma/sass"]
      }
    }
  },
  npm: {
    enabled: true,
  }
}
