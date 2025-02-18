import { render } from '@testing-library/react-native';
import RootLayout from './_layout';

// Mock expo-router since we don't want to test the actual navigation
jest.mock('expo-router', () => ({
  Stack: jest.fn().mockImplementation(({ screenOptions }) => {
    const { View } = require('react-native');  // Import inside the mock
    return (
      <View 
        testID="mock-stack" 
        accessibilityState={{ screenOptions: JSON.stringify(screenOptions) }}
      />
    );
  }),
}));

console.log('Test suite starting...', new Date().toISOString());

describe('RootLayout', () => {
  it('renders Stack navigator with correct screen options', () => {
    const { getByTestId } = render(<RootLayout />);
    
    // Get the mock function
    const { Stack } = require('expo-router');
    expect(Stack).toHaveBeenCalledWith(
      expect.objectContaining({
        screenOptions: {
          headerTitle: "GCal Alarms",
          headerTitleAlign: "center",
        }
      }),
      expect.anything()
    );
    
    const stack = getByTestId('mock-stack');
    expect(JSON.parse(stack.props.accessibilityState.screenOptions)).toEqual({
      headerTitle: "GCal Alarms",
      headerTitleAlign: "center",
    });
  });
}); 
