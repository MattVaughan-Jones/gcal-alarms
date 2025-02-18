import type { Config } from 'jest';

// Packages that need to be transformed by Jest
const transformPackages = [
//   'jest-react-native',
  'react-native',
  '@react-native',
//   '@react-native-community',
  'expo',
//   '@expo',
//   '@expo-google-fonts',
//   'react-navigation',
//   '@react-navigation',
//   '@unimodules',
//   'unimodules',
//   'sentry-expo',
//   'native-base',
//   'react-native-svg'
];

const config: Config = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx'],
  transformIgnorePatterns: [
    `node_modules/(?!(${transformPackages.join('|')}))`
  ],
  collectCoverageFrom: [
    '**/*.{ts,tsx}',
    '!**/coverage/**',
    '!**/node_modules/**',
    '!**/babel.config.js',
    '!**/jest.setup.js'
  ],
  testMatch: [
    '**/?(*.)+(spec|test).ts?(x)'
  ]
};

export default config; 