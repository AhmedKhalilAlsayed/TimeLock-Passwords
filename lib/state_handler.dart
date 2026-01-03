/// make every return through it, to always add an error state
/// classes (logic) >> Domain (the errors that domain interested)
/// Data >> Domain (the errors that domain interested)
/// Domain >> UI (the errors that UI interested)
///
class StateHandler<State extends Enum, Value> {
  State state;
  Value? value;

  StateHandler(this.state, this.value);
}

