if (!process.env.EXPO_PUBLIC_GOOGLE_AUTH_URL) {
  throw new Error('EXPO_PUBLIC_GOOGLE_AUTH_URL is not defined');
}
if (!process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID) {
  throw new Error('EXPO_PUBLIC_GOOGLE_CLIENT_ID is not defined');
}

export const GOOGLE_AUTH_URL: string = process.env.EXPO_PUBLIC_GOOGLE_AUTH_URL;
export const GOOGLE_WEB_CLIENT_ID: string = process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID;
