defmodule Level.Posts.Post do
  @moduledoc """
  The Post schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Level.Groups.Group
  alias Level.Mentions.UserMention
  alias Level.Posts.PostGroup
  alias Level.Posts.Reply
  alias Level.Spaces.Space
  alias Level.Spaces.SpaceUser

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "posts" do
    field :state, :string, read_after_writes: true
    field :body, :string

    belongs_to :space, Space
    belongs_to :author, SpaceUser, foreign_key: :space_user_id
    many_to_many :groups, Group, join_through: PostGroup
    has_many :replies, Reply
    has_many :user_mentions, UserMention

    # Holds the subscription state for the current user.
    # This is populated automatically by the posts_base_query.
    field :subscription_state, :string, virtual: true

    # Used for paginating
    field :last_pinged_at, :naive_datetime, virtual: true

    timestamps()
  end

  @doc false
  def create_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:space_id, :space_user_id, :body])
    |> validate_required([:body])
  end
end
