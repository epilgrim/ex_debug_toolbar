defmodule ExDebugToolbar.Data.TimelineTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.Timeline
  alias ExDebugToolbar.Data.Timeline.Event

  test "tracks events and computes duration" do
    timeline =
      %Timeline{}
      |> Timeline.start_event("name")
      |> Timeline.finish_event("name")

    assert timeline.events |> length == 1
    event = timeline.events |> List.first

    assert %Event{name: "name", started_at: %DateTime{}} = event
    assert event.duration > 0
  end

  test "accepts nested events" do
    timeline =
      %Timeline{}
      |> Timeline.start_event("A")
      |> Timeline.start_event("A-B")
      |> Timeline.finish_event("A-B")
      |> Timeline.start_event("A-B")
      |> Timeline.finish_event("A-B")
      |> Timeline.finish_event("A")
      |> Timeline.start_event("C")
      |> Timeline.start_event("C-D")
      |> Timeline.finish_event("C-D")
      |> Timeline.start_event("C-E")
      |> Timeline.finish_event("C-E")
      |> Timeline.finish_event("C")

    [first_event, second_event] = timeline.events
    assert first_event.name == "C"
    assert first_event.events |> Enum.at(0) |> Map.fetch!(:name) == "C-E"
    assert first_event.events |> Enum.at(1) |> Map.fetch!(:name) == "C-D"

    assert second_event.name == "A"
    assert second_event.events |> Enum.at(0) |> Map.fetch!(:name) == "A-B"
    assert second_event.events |> Enum.at(1) |> Map.fetch!(:name) == "A-B"
  end

  test "raises an error when closing an event that is not open" do
    assert_raise RuntimeError, fn ->
      %Timeline{}
      |> Timeline.start_event("A")
      |> Timeline.finish_event("B")
    end
    assert_raise RuntimeError, fn ->
      %Timeline{}
      |> Timeline.start_event("A")
      |> Timeline.start_event("B")
      |> Timeline.finish_event("C")
    end
  end

  test "raises an error when closing an event that is not the last one opened" do
    assert_raise RuntimeError, fn ->
      %Timeline{}
      |> Timeline.start_event("A")
      |> Timeline.start_event("C")
      |> Timeline.finish_event("A")
    end
  end

  describe "duration/1" do
    test "retuns total duration of all events" do
      timeline =
        %Timeline{}
        |> Timeline.start_event("A")
        |> Timeline.finish_event("A")
        |> Timeline.start_event("B")
        |> Timeline.finish_event("B")
      assert Timeline.duration(timeline) == timeline.events |> Enum.map(&(&1.duration)) |> Enum.sum
    end

    test "it ignores unfinished events" do
      timeline =
        %Timeline{}
        |> Timeline.start_event("A")
      assert timeline |> Timeline.duration == 0
    end
  end
end
