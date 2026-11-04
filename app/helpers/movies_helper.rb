module MoviesHelper
  # Is the movie list currently sorted by this column?
  def sorted_by?(column)
    @sort_by.to_s == column.to_s
  end

  # Value for the header cell's `aria-sort` attribute. This is what tells a
  # screen reader which column the table is sorted by, so only the sorted
  # column may have a value other than "none".
  def sort_aria(column)
    sorted_by?(column) ? 'ascending' : 'none'
  end

  # Bootstrap classes that highlight the header of the sorted column. bg-info
  # is a light cyan, so the text on top of it has to stay dark to keep enough
  # contrast to be readable (see the th.bg-info rule in rottenpotatoes.css).
  def sort_classes(column)
    'hilite bg-info text-dark' if sorted_by?(column)
  end

  # The little arrow next to the sorted column's name. It is decorative:
  # `aria-hidden` keeps screen readers from announcing "▲", because the
  # `aria-sort` attribute above already says the same thing in words.
  def sort_indicator(column)
    tag.span(' ▲', 'aria-hidden': true) if sorted_by?(column)
  end

  # The ratings that are currently checked, in the shape `params` expects:
  # ['G', 'R'] becomes {'G' => '1', 'R' => '1'}. Passing this to movies_path
  # is what makes a column header "remember" the checkbox filters.
  def ratings_for_url
    @ratings_to_show.index_with('1')
  end
end
