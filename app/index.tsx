import { Button, Text, View } from 'react-native';
import * as AuthSession from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import { GOOGLE_AUTH_URL } from '../constants';
import { fetch } from 'expo/fetch';
import { useEffect, useState } from 'react';

WebBrowser.maybeCompleteAuthSession();
const redirectUri = AuthSession.makeRedirectUri();

export default function Index() {
  const [manualDiscovery, setManualDiscovery] = useState<any>(null);

  useEffect(() => {
    const fetchDiscovery = async () => {
      if (!GOOGLE_AUTH_URL) {
        throw new Error('GOOGLE_AUTH_URL is not defined');
      }
      console.log(GOOGLE_AUTH_URL)
      const response = await fetch(GOOGLE_AUTH_URL);
      console.log(response);
      setManualDiscovery(response);
    };

    fetchDiscovery();
  }, []);

  const [request, result, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: 'native.code',
      redirectUri,
      scopes: ['openid', 'profile', 'email', 'offline_access'],
    },
    manualDiscovery
  );

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Button title="Login!" disabled={!request} onPress={() => promptAsync()} />
      {result && <Text>{JSON.stringify(result, null, 2)}</Text>}
    </View>
  );
}
