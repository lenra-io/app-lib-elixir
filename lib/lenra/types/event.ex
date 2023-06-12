defmodule Lenra.Types.Event do
  @derive [Jason.Encoder]
  defstruct value: nil

  @type t :: %__MODULE__{
          value: any()
        }
end
