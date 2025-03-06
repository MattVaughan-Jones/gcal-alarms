import { Button, Text, View } from 'react-native';
import * as AuthSession from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import { GOOGLE_AUTH_URL, GOOGLE_CLIENT_ID } from '../constants';
import { useEffect, useState } from 'react';

WebBrowser.maybeCompleteAuthSession();
const redirectUri = AuthSession.makeRedirectUri();

console.log('Redirect URI:', redirectUri);

export default function Index() {
  const [discovery, setDiscovery] = useState<AuthSession.DiscoveryDocument | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchDiscovery = async () => {
      try {
        if (!GOOGLE_AUTH_URL) {
          throw new Error('GOOGLE_AUTH_URL is not defined');
        }
        const response = await fetch(GOOGLE_AUTH_URL);
        const discoveryDoc = await response.json();
        setDiscovery(discoveryDoc);
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Failed to fetch discovery document');
        console.error('Discovery Error:', e);
      }
    };
    console.log("============== NEW REFRESH ===============")
    fetchDiscovery();
  }, []);

  const [request, response, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: GOOGLE_CLIENT_ID || '',
      responseType: 'code',
      redirectUri,
      usePKCE: true,
      scopes: [
        'openid',
        'profile',
        'email',
        'offline_access',
        'https://www.googleapis.com/auth/calendar.readonly'
      ],
    },
    {
      authorizationEndpoint: (discovery as any)?.authorization_endpoint,
      tokenEndpoint: (discovery as any)?.token_endpoint,
      revocationEndpoint: (discovery as any)?.revocation_endpoint,
    }
  );

  useEffect(() => {
    if (response && 'type' in response) {
      if (response.type === 'success' && 'params' in response) {
        const { code } = response.params;
        // We'll exchange this code for tokens in the next step
      } else if (response.type === 'error') {
        setError(response.error?.message || 'Authentication failed');
      }
    }
  }, [response]);

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Button 
        title="Login with Google!" 
        disabled={!request} 
        onPress={() => promptAsync()} 
      />
      {error && <Text style={{ color: 'red', marginTop: 10 }}>{error}</Text>}
      {response && <Text>Auth response received! Check the logs.</Text>}
    </View>
  );
}
