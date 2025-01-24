import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Section,
  Table,
  Box,
  Flex,
  Input,
  Modal,
  Stack,
} from '../components';
import { Window } from '../layouts';

// Types for the main request manager
type MentorRequest = {
  id: string;
  req_type: string;
  owner: string | null;
  owner_ckey: string;
  owner_name: string;
  message: string;
  additional_info: string;
  timestamp: number;
  timestamp_str: string;
  claimed_by: string | null;
  answer_status: 'ANSWERED' | 'NOT ANSWERED';
};

type RequestData = {
  requests: MentorRequest[];
  current_user: string;
};

// Main Request Manager Component
export const RequestManagerMonke2 = (props) => {
  const { act, data } = useBackend<RequestData>();
  const { requests = [], current_user } = data;
  const [replyModal, setReplyModal] = useLocalState('replyModal', null);

  return (
    <Window title="Mentor Request Manager" width={800} height={600}>
      <Window.Content scrollable>
        <Section>
          <Table>
            <Table.Row header>
              <Table.Cell>Time</Table.Cell>
              <Table.Cell>Player</Table.Cell>
              <Table.Cell>Message</Table.Cell>
              <Table.Cell>Status</Table.Cell>
              <Table.Cell>Actions</Table.Cell>
            </Table.Row>
            {requests.map((request) => (
              <RequestRow
                key={request.id}
                request={request}
                currentUser={current_user}
                act={act}
                onReply={() => setReplyModal(request)}
              />
            ))}
          </Table>
        </Section>
        <ReplyModal request={replyModal} onClose={() => setReplyModal(null)} />
      </Window.Content>
    </Window>
  );
};

// Reply Modal Component
const ReplyModal = ({ request, onClose }) => {
  const { act } = useBackend();
  const [message, setMessage] = useLocalState('replyMessage', '');
  const [markAnswered, setMarkAnswered] = useLocalState('markAnswered', false);

  if (!request) {
    return null;
  }

  const handleSubmit = () => {
    if (message.trim()) {
      act('reply', {
        id: request.id,
        message: message,
        mark_answered: markAnswered,
      });
      setMessage('');
      setMarkAnswered(false);
      onClose();
    }
  };

  return (
    <Modal>
      <Section title={`Reply to ${request.owner_name}`}>
        <Stack vertical>
          <Stack.Item>
            <Box mb={1}>Original message: {request.message}</Box>
          </Stack.Item>
          <Stack.Item>
            <Input
              fluid
              value={message}
              placeholder="Type your reply..."
              onInput={(e, value) => setMessage(value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault();
                  handleSubmit();
                }
              }}
            />
          </Stack.Item>
          <Stack.Item>
            <Button.Checkbox
              checked={markAnswered}
              onClick={() => setMarkAnswered(!markAnswered)}
            >
              Mark as Answered
            </Button.Checkbox>
          </Stack.Item>
          <Stack.Item>
            <Box>
              <Button content="Cancel" onClick={onClose} mr={1} />
              <Button
                content="Send"
                color="good"
                disabled={!message.trim()}
                onClick={handleSubmit}
              />
            </Box>
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};

// Conversation Window Component
export const RequestConversation = (props) => {
  const { data } = useBackend();
  const { conversation_history = [], current_user, request } = data;

  return (
    <Window
      title={`Conversation with ${request.owner_name}`}
      width={600}
      height={400}
    >
      <Window.Content scrollable>
        <Section>
          <Box mb={2}>
            <Box color="label" mb={1}>
              Original Request:
            </Box>
            <Box ml={2}>{request.message}</Box>
          </Box>
          <Stack vertical>
            {conversation_history.map((msg, i) => (
              <Stack.Item key={i}>
                <Box
                  backgroundColor={
                    msg.sender === current_user ? 'blue' : 'grey'
                  }
                  style={{
                    padding: '0.5em',
                    borderRadius: '8px',
                    maxWidth: '80%',
                    marginLeft: msg.sender === current_user ? 'auto' : '0',
                  }}
                >
                  <Box fontSize="11px" opacity={0.8} mb={0.5}>
                    {msg.sender} - {msg.timestamp_str}
                  </Box>
                  {msg.message}
                </Box>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

// Row Component
const RequestRow = ({ request, currentUser, act, onReply }) => {
  const {
    id,
    owner_ckey,
    owner_name,
    message,
    timestamp_str,
    claimed_by,
    answer_status,
  } = request;

  const isClaimedByOther = claimed_by && claimed_by !== currentUser;
  const claimStatus = claimed_by ? `Claimed by ${claimed_by}` : 'Unclaimed';

  return (
    <Table.Row>
      <Table.Cell>{timestamp_str}</Table.Cell>
      <Table.Cell>
        {owner_name} ({owner_ckey})
      </Table.Cell>
      <Table.Cell>{message}</Table.Cell>
      <Table.Cell>
        <Box
          color={claimed_by ? (isClaimedByOther ? 'red' : 'green') : 'label'}
        >
          {claimStatus}
        </Box>
        <Box color={answer_status === 'ANSWERED' ? 'green' : 'red'}>
          {answer_status}
        </Box>
      </Table.Cell>
      <Table.Cell>
        <Flex gap={1}>
          <Flex.Item>
            <Button
              icon="reply"
              tooltip={
                isClaimedByOther
                  ? 'Cannot reply - claimed by another mentor'
                  : 'Reply'
              }
              onClick={onReply}
              disabled={isClaimedByOther}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="eye"
              tooltip="Follow"
              onClick={() => act('follow', { id })}
            />
          </Flex.Item>
          <Flex.Item>
            {!claimed_by ? (
              <Button
                icon="hand"
                color="green"
                tooltip="Claim"
                onClick={() => act('claim', { id })}
              />
            ) : (
              claimed_by === currentUser && (
                <Button
                  icon="hand-back"
                  color="red"
                  tooltip="Unclaim"
                  onClick={() => act('unclaim', { id })}
                />
              )
            )}
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="comments"
              tooltip="View Conversation"
              onClick={() => act('view_conversation', { id })}
            />
          </Flex.Item>
        </Flex>
      </Table.Cell>
    </Table.Row>
  );
};
