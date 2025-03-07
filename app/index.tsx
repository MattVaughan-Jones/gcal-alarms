import { Button, Text, View } from 'react-native';
import { useAuth } from '../context/AuthContext';

export default function App() {
  const { isLoading, isSignedIn, userInfo, signIn, signOut } = useAuth();

  if (isLoading) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        <Text>Loading...</Text>
      </View>
    );
  }

  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      {isSignedIn ? (
        <>
          <Text>Welcome, {userInfo?.name}!</Text>
          <Button title="Sign Out" onPress={signOut} />
        </>
      ) : (
        <Button title="Sign in with Google" onPress={signIn} />
      )}
    </View>
  );
}
