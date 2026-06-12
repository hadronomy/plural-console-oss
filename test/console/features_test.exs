defmodule Console.FeaturesTest do
  use Console.DataCase, async: false
  alias Console.Plural.Queries
  alias Console.Features
  use Mimic

  setup :set_mimic_global
  setup do
    System.delete_env("PLURAL_CONSOLE_OSS_STANDALONE")

    on_exit(fn ->
      System.delete_env("PLURAL_CONSOLE_OSS_STANDALONE")
    end)
  end

  describe "available?/1" do
    test "it can fetch features and cache them locally" do
      body = Jason.encode!(%{
        query: Queries.account_query(),
        variables: %{}
      })

      account = %{id: "id", availableFeatures: %{vpn: true}}
      expect(HTTPoison, :post, fn _, ^body, _ ->
        {:ok, %{body: Jason.encode!(%{data: %{account: account}})}}
      end)

      {:ok, pid} = Features.start()

      send pid, :poll

      res = GenServer.call(pid, :fetch)

      assert res.vpn
    end

    test "it enables local CD when open-source standalone mode is explicit" do
      System.put_env("PLURAL_CONSOLE_OSS_STANDALONE", "true")

      {:ok, pid} = Features.start()

      {features, account} = :sys.get_state(pid)

      assert features.cd
      assert features.deployments
      assert account.subscription.plan.name == "Open Source Standalone"
    end

    test "it keeps upstream feature behavior without standalone mode" do
      {:ok, pid} = Features.start()

      {features, account} = :sys.get_state(pid)

      refute features.cd
      refute account
    end
  end

  describe "#check_license?/0" do
    test "if a license key is provided, it will verify" do
      if System.get_env("CONSOLE_LICENSE") do
        key = System.get_env("CONSOLE_LICENSE")
        {features, account} = Features.check_license(key)

        assert features.cd
        assert account.subscription.plan.name == "Enterprise"
      end
    end
  end
end
