import { Button, Text, View } from 'react-native';
import { GoogleSignin, statusCodes } from '@react-native-google-signin/google-signin';
import { useEffect, useState } from 'react';
import { GOOGLE_WEB_CLIENT_ID } from '../constants';

// Configure Google Sign-In
GoogleSignin.configure({
  webClientId: GOOGLE_WEB_CLIENT_ID,
  offlineAccess: true,
});

export default function App() {
  const [error, setError] = useState<string | null>(null);

  const signIn = async () => {
    try {
      console.log('Current configuration:', {
        webClientId: GOOGLE_WEB_CLIENT_ID,
      });
      
      console.log('Checking Play Services...');
      await GoogleSignin.hasPlayServices();
      
      console.log('Attempting sign in...');
      const userInfo = await GoogleSignin.signIn();
      console.log('User Info:', userInfo);
      
      const tokens = await GoogleSignin.getTokens();
      console.log('Tokens:', tokens);
      
      // Handle successful sign-in
    } catch (e: any) {
      console.error('Detailed error:', {
        code: e.code,
        message: e.message,
        stack: e.stack
      });
      if (e.code === statusCodes.SIGN_IN_CANCELLED) {
        setError('User cancelled the login flow');
      } else if (e.code === statusCodes.IN_PROGRESS) {
        setError('Sign in is in progress');
      } else if (e.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
        setError('Play services not available');
      } else {
        setError(`Something went wrong: ${e.message}`);
      }
    }
  };

  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Button title="Sign in with Google" onPress={signIn} />
      {error && <Text style={{ color: 'red', marginTop: 20 }}>{error}</Text>}
    </View>
  );
}
