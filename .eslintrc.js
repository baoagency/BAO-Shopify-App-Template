module.exports = {
  extends: [
    '@by-association-only/eslint-config-unisian',
    'plugin:react/recommended'
  ],
  plugins: ['react'],
  globals: {
    document: true,
    window: true,
    ShopifyApp: true,
  }
}
