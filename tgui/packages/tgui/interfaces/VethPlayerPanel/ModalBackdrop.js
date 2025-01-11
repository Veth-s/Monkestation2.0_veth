import { Box } from '../../components';

export const ModalBackdrop = () => (
  <Box
    position="fixed"
    top="0"
    left="0"
    right="0"
    bottom="0"
    backgroundColor="rgba(0, 0, 0, 0.5)"
    style={{
      zIndex: 999,
    }}
  />
);
