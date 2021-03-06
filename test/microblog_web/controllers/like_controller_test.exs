defmodule MicroblogWeb.LikeControllerTest do
  use MicroblogWeb.ConnCase

  alias Microblog.Feedback
  alias Microblog.Feedback.Like

    def create_attrs() do
      {:ok, user} = Microblog.Account.create_user(%{bio: "some bio", email: "some email", handle: "some handle", name: "some name"})
      {:ok, post} = Microblog.Blog.create_post(%{body: "some body", user_id: user.id})
      %{user_id: user.id, post_id: post.id}
    end

  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:like) do
    {:ok, like} = Feedback.create_like(create_attrs())
    like
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all likes", %{conn: conn} do
      conn = get conn, like_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  @tag :skip
  describe "create like" do
    test "renders like when data is valid", %{conn: conn} do
      conn = post conn, like_path(conn, :create), like: create_attrs()
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, like_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, like_path(conn, :create), like: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  @tag :skip
  describe "update like" do
    setup [:create_like]

    test "renders like when data is valid", %{conn: conn, like: %Like{id: id} = like} do
      conn = put conn, like_path(conn, :update, like), like: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, like_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn, like: like} do
      conn = put conn, like_path(conn, :update, like), like: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete like" do
    setup [:create_like]

    test "deletes chosen like", %{conn: conn, like: like} do
      conn = delete conn, like_path(conn, :delete, like)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, like_path(conn, :show, like)
      end
    end
  end

  defp create_like(_) do
    like = fixture(:like)
    {:ok, like: like}
  end
end
