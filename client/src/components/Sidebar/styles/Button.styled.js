import styled from 'styled-components'

export const Container = styled.div`
  display: flex;
  justify-content: flex-start;
  align-items: center;

  padding: 10px;

  &:hover {
    background: #b0e0e6;
  }

  background: ${(props) => (props.isSelected ? '#B0E0E6' : 'white')};
`
export const Text = styled.div`
  font-family: 'Roboto';
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  /* or 150% */

  letter-spacing: 0.1px;

  /* Black / High Emphasis */

  color: rgba(0, 0, 0, 0.87);

  padding-left: 10px;
`
