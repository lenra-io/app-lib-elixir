defmodule Mix.Tasks.Lenra.Gen.Listener do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generate a listener for the Lenra app"

  # Option aliases
  @aliases [
    p: :path
  ]

  # Options
  @switches [
    path: :string,
    help: :boolean
  ]

  @base_dir "lib"
  @default_path "listeners"

  def run(args) do
    case OptionParser.parse!(args, strict: @switches, aliases: @aliases) do
      {[help: true], _} ->
        explain_message()
        |> IO.puts()

      {opts, [module | listeners]} ->
        path = opts[:path] || @default_path
        listener_path = Path.join(Mix.Project.config()[:app] |> Atom.to_string(), path)
        gen_module(module, listeners, listener_path)

      {_opts, []} ->
        Mix.raise("You MUST specify the module name.\n\n#{explain_message()}")
    end
  end

  def explain_message() do
    """
    mix lenra.gen.listener expect a module name and optionally a list of listeners.
    For example :

      mix lenra.gen.listener Counter increment decrement
      mix lenra.gen.listener Counter
      mix lenra.gen.listener Counter --path <custom_listener_dir>

    This will generate a listener at lib/app/listener/counter.ex
    """
  end

  def gen_module(module, [], listener_dir) do
    gen_module(module, ["my_listener"], listener_dir)
  end

  def gen_module(module, listeners, listener_dir) do
    filename = "#{Macro.underscore(module)}.ex"
    full_module = Macro.camelize(Path.join(listener_dir, module))
    full_path = Path.join([@base_dir, listener_dir, filename])

    if overwrite?(full_path) do
      clean_listeners = listeners |> Enum.map(&Macro.underscore/1)

      listener_content = listener_template(mod_name: full_module, listeners: clean_listeners)
      create_file(full_path, listener_content)
    end
  end

  embed_template(:listener, """
  defmodule <%= @mod_name %> do
    use Lenra.Listener
    <%= for listener <- @listeners do %>
    deflistener :<%= listener %>, _params do
      # TODO : Implement
    end
  <% end %>end
  """)
end
