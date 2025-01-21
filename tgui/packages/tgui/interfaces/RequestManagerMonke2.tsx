// Define minimal interface for our data
interface RequestData {
  requests: Array<{
    id: string;
    owner_ckey: string;
    message: string;
    timestamp_str: string;
    claimed_by: string | null;
    answer_status: 'ANSWERED' | 'NOT ANSWERED'; // Add this new field
  }>;
  current_user: string;
}

import { useBackend } from '../backend';
import { Button, Section, Table, Box, Flex } from '../components';
import { Window } from '../layouts';

export const RequestManagerMonke2 = (props) => {
  const { act, data } = useBackend<RequestData>();
  const { requests = [] } = data;

  // Add this function to handle viewing conversations
  const handleViewConversation = (id: string) => {
    act('view_conversation', { id: id });
  };

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
                onViewConversation={() => handleViewConversation(request.id)}
              />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

const RequestRow = (props) => {
  const { act, data } = useBackend<RequestData>();
  const {
    request: {
      id,
      owner_ckey,
      message,
      timestamp_str,
      claimed_by,
      answer_status,
    },
    onViewConversation,
  } = props;
  const currentUser = data.current_user;
  const isClaimedByOther = claimed_by && claimed_by !== currentUser;

  return (
    <Table.Row>
      <Table.Cell>{timestamp_str}</Table.Cell>
      <Table.Cell>{owner_ckey}</Table.Cell>
      <Table.Cell>{message}</Table.Cell>
      <Table.Cell>
        <Box
          color={claimed_by ? (isClaimedByOther ? 'red' : 'green') : 'label'}
        >
          {claimed_by ? `Claimed by ${claimed_by}` : 'Unclaimed'}
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
              onClick={() => {
                act('reply', {
                  id: id,
                  mark_answered: true, // Add this parameter
                });
              }}
              disabled={isClaimedByOther}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="eye"
              tooltip="Follow"
              onClick={() => act('follow', { id: id })}
            />
          </Flex.Item>
          <Flex.Item>
            {!claimed_by ? (
              <Button
                icon="hand"
                color="green"
                tooltip="Claim"
                onClick={() => act('claim', { id: id })}
              />
            ) : (
              claimed_by === currentUser && (
                <Button
                  icon="hand-back"
                  color="red"
                  tooltip="Unclaim"
                  onClick={() => act('unclaim', { id: id })}
                />
              )
            )}
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="comments"
              tooltip="View Conversation"
              onClick={onViewConversation}
            />
          </Flex.Item>
        </Flex>
      </Table.Cell>
    </Table.Row>
  );
};
