import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Section, Box } from '../components';
// Define interface for conversation data
interface ConversationData {
  messages: Array<{
    sender: string;
    message: string;
    timestamp_str: string;
  }>;
  request_id: string;
  owner_ckey: string;
}

// Create new window component for conversation view
export const RequestConversation = (props) => {
  const { data } = useBackend<ConversationData>();
  const { messages = [], owner_ckey } = data;

  return (
    <Window title={`Conversation with ${owner_ckey}`} width={600} height={400}>
      <Window.Content scrollable>
        <Section>
          {messages.map((msg, index) => (
            <Box
              key={index}
              mb={1}
              p={1}
              backgroundColor={
                msg.sender === owner_ckey ? '#352a2a' : '#2a2a35'
              }
            >
              <Box color="label" mb={0.5}>
                {msg.sender} - {msg.timestamp_str}
              </Box>
              <Box>{msg.message}</Box>
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
