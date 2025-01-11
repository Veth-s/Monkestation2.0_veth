import { Box, Button, Section, TextArea } from '../../components';

type MessageModalProps = {
  selectedPlayerCkey: string;
  inputMessage: string;
  onInputMessageChange: (value: string) => void;
  onSendPrivateMessage: () => void;
  onClose: () => void;
};

export const MessageModal = ({
  selectedPlayerCkey,
  inputMessage,
  onInputMessageChange,
  onSendPrivateMessage,
  onClose,
}: MessageModalProps) => (
  <Box
    className="Modal"
    position="fixed"
    top="50%"
    left="50%"
    style={{
      transform: 'translate(-50%, -50%)',
      backgroundColor: '#252525',
      border: '1px solid #404040',
      borderRadius: '0.25rem',
      padding: '0.5rem',
      width: '400px',
      zIndex: 1000,
    }}
  >
    <Section
      title={`Send Private Message to ${selectedPlayerCkey}`}
      buttons={<Button icon="times" color="red" onClick={onClose} />}
    >
      <Box mb={2}>
        <Box color="label" mb={1}>
          Enter your message:
        </Box>
        <TextArea
          placeholder="Type your adminPM here..."
          value={inputMessage}
          onChange={(e, value) => onInputMessageChange(value)}
          height="100px"
          style={{
            resize: 'none',
            width: '100%',
            padding: '0.5em',
            'margin-bottom': '0.5em',
            'background-color': '#333333',
            color: '#ffffff',
            border: '1px solid #404040',
          }}
        />
      </Box>
      <Box textAlign="right">
        <Button
          content="Send"
          color="good"
          onClick={onSendPrivateMessage}
          mr={1}
        />
        <Button content="Cancel" onClick={onClose} />
      </Box>
    </Section>
  </Box>
);
