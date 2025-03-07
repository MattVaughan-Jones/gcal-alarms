import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { GoogleSignin, User } from '@react-native-google-signin/google-signin';
import * as SecureStore from 'expo-secure-store';
import { GOOGLE_WEB_CLIENT_ID } from '@/constants';

// Add this near the top of the file, before the AuthProvider
GoogleSignin.configure({
  webClientId: GOOGLE_WEB_CLIENT_ID, // Get this from Google Cloud Console
  // iosClientId: 'IOS_CLIENT_ID', // Required if using iOS
  // offlineAccess: true, // to access Google API on behalf of the user FROM YOUR SERVER
});

interface AuthState {
  isLoading: boolean;
  isSignedIn: boolean;
  userInfo: {
    email: string;
    name: string;
    id: string;
  } | null;
}

interface AuthContextType extends AuthState {
  signIn: () => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | null>(null);

// useAuth hook
export function useAuth() {
  const context = useContext(AuthContext);
  if (context === null) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [authState, setAuthState] = useState<AuthState>({
    isLoading: true,
    isSignedIn: false,
    userInfo: null,
  });

  useEffect(() => {
    checkAuthState();
  }, []);

  const checkAuthState = async () => {
    try {
      const isSignedIn = GoogleSignin.getCurrentUser();
      if (isSignedIn) {
        setAuthState({
          isLoading: false,
          isSignedIn: true,
          userInfo: {
            email: isSignedIn.user.email,
            name: isSignedIn.user.name || '',
            id: isSignedIn.user.id,
          },
        });
      } else {
        setAuthState({
          isLoading: false,
          isSignedIn: false,
          userInfo: null,
        });
      }
    } catch (error) {
      console.error('Auth state check failed:', error);
      setAuthState({
        isLoading: false,
        isSignedIn: false,
        userInfo: null,
      });
    }
  };

  const signIn = async () => {
    try {
      await GoogleSignin.hasPlayServices();
      const userInfo = await GoogleSignin.signIn();
      
      if (!userInfo.data) {
        throw new Error('User info not found');
      }

      await SecureStore.setItemAsync('accessToken', (await GoogleSignin.getTokens()).accessToken);
      
      setAuthState({
        isLoading: false,
        isSignedIn: true,
        userInfo: {
          email: userInfo.data.user.email,
          name: userInfo.data.user.name || '',
          id: userInfo.data.user.id,
        },
      });
    } catch (error) {
      console.error('Sign in failed:', error);
      throw error;
    }
  };

  const signOut = async () => {
    try {
      await GoogleSignin.signOut();
      await SecureStore.deleteItemAsync('accessToken');
      setAuthState({
        isLoading: false,
        isSignedIn: false,
        userInfo: null,
      });
    } catch (error) {
      console.error('Sign out failed:', error);
      throw error;
    }
  };

  return (
    <AuthContext.Provider value={{ ...authState, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}
