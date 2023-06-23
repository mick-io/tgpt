defmodule TGPT do
  def run do
    IO.puts("T-GPTx - Terminal Based LLM Goodness <(^_^)>")

    # Start an Agent
    Agent.start_link(fn -> nil end, name: :api_key_store)

    # Check the environment for the API key
    api_key = System.get_env("OPENAI_API_KEY")

    # If api_key is nil, prompt the user for the API key
    if is_nil(api_key) do
      IO.puts("Enter your OpenAI API Key:")
      ^api_key = IO.gets("> ") |> String.trim()
    end

    # Store the API key in the Agent
    Agent.update(:api_key_store, fn _ -> api_key end)

    prompt_for_input()
  end

  defp prompt_for_input do
    IO.puts("Enter your prompt (or 'q' to quit):")
    input = IO.gets("> ")

    case String.trim(input) do
      "q" ->
        IO.puts("Thanks for all the fish.")

      prompt ->
        get_chatgpt_response(prompt)
        prompt_for_input()
    end
  end

  defp get_chatgpt_response(prompt) do
    # Retrieve the API key from the Agent
    api_key = Agent.get(:api_key_store, fn stored_api_key -> stored_api_key end)

    url = "https://api.openai.com/v1/engines/davinci-codex/completions"

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    payload = Poison.encode!(%{"prompt" => prompt, "max_tokens" => 50})

    case HTTPoison.post(url, payload, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        response = Poison.decode!(body)
        IO.puts("ChatGPT Response: #{response["choices"] |> List.first() |> Map.get("text")}")
        prompt_for_input()

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Error: #{status_code} - #{body}")
        prompt_for_input()

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("HTTP Error: #{reason}")
        prompt_for_input()
    end
  end
end
