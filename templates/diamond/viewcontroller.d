module controllers.$1controller;

import diamond.controllers;

final class $2Controller(TView) : WebController!TView
{
  public:
  final:
  this(TView view)
  {
    super(view);
  }

  @HttpDefault $1()
  {
	return Status.success;
  }
}
