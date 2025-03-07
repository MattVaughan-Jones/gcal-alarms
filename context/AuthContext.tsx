import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { GoogleSignin, User } from '@react-native-google-signin/google-signin';
import * as SecureStore from 'expo-secure-store';

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

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    isLoading: true,
    isSignedIn: false,
    userInfo: null,
  });

  useEffect(() => {
    // Check if user is signed in on app launch
    checkAuthState();
  }, []);

  const checkAuthState = async () => {
    try {
      const isSignedIn = await GoogleSignin.getCurrentUser();
      if (isSignedIn) {
        setState({
          isLoading: false,
          isSignedIn: true,
          userInfo: {
            email: isSignedIn.user.email,
            name: isSignedIn.user.name || '',
            id: isSignedIn.user.id,
          },
        });
      } else {
        setState({
          isLoading: false,
          isSignedIn: false,
          userInfo: null,
        });
      }
    } catch (error) {
      console.error('Auth state check failed:', error);
      setState({
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
      const tokens = await GoogleSignin.getTokens();

      if (!userInfo.data) {
        throw new Error('User info not found');
      }

      await SecureStore.setItemAsync('accessToken', tokens.accessToken);
      
      setState({
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
      setState({
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
    <AuthContext.Provider value={{ ...state, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
} 