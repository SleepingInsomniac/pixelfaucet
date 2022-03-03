require "../line"

module PF
  class Sprite
    # Draw a filled in triangle
    def fill_triangle(p1 : Vector2, p2 : Vector2, p3 : Vector2, pixel : Pixel = Pixel.new)
      # Sort points from top to bottom
      p1, p2 = p2, p1 if p2.y < p1.y
      p1, p3 = p3, p1 if p3.y < p1.y
      p2, p3 = p3, p2 if p3.y < p2.y

      # sort left and right edges by run / rise
      line_left = PF::Line.new(p1, p2)
      line_right = PF::Line.new(p1, p3)

      if line_left.run / line_left.rise > line_right.run / line_right.rise
        line_left, line_right = line_right, line_left
      end

      # calculate line slopes
      slope_left = line_left.slope
      slope_right = line_right.slope

      c = p1.y # offset
      height = p3.y - p1.y
      mid = p2.y - p1.y

      0.upto(height) do |y|
        if slope_left == 0
          # When there is no rise, set the x value directly
          x_left = line_left.p2.x
        else
          x_left = ((y - (line_left.p1.y - p1.y)) / slope_left).round.to_i + line_left.p1.x
        end

        if slope_right == 0
          x_right = line_right.p2.x
        else
          x_right = ((y - (line_right.p1.y - p1.y)) / slope_right).round.to_i + line_right.p1.x
        end

        x_left.upto(x_right) do |x|
          draw_point(x, y + c, pixel)
        end

        if y == mid
          if line_left.p2 == p2
            line_left = PF::Line.new(p2, p3)
            slope_left = line_left.slope
          else
            line_right = PF::Line.new(p2, p3)
            slope_right = line_right.slope
          end
        end
      end
    end

    # ditto
    def fill_triangle(points : Enumerable(Vector2), pixel : Pixel = Pixel.new)
      fill_triangle(points[0], points[1], points[2], pixel)
    end

    # Draw a textured triangle
    def fill_triangle(p1 : Vector2, p2 : Vector2, p3 : Vector2, t1 : Vector2, t2 : Vector2, t3 : Vector2, sprite : Sprite, color : Pixel = Pixel.white)
      # Sort points from top to bottom
      p1, p2, t1, t2 = p2, p1, t2, t1 if p2.y < p1.y
      p1, p3, t1, t3 = p3, p1, t3, t1 if p3.y < p1.y
      p2, p3, t2, t3 = p3, p2, t3, t2 if p3.y < p2.y

      # Create lines starting at p1 to the other lower points
      line_left = PF::Line.new(p1, p2)
      line_right = PF::Line.new(p1, p3)
      tl_left = PF::Line.new(t1, t2)
      tl_right = PF::Line.new(t1, t3)

      # Sort left and right edges by run / rise
      # if the first line goes to the right more than the right, then swap (first line is on the right)
      if line_left.run / line_left.rise > line_right.run / line_right.rise
        line_left, line_right = line_right, line_left
        tl_left, tl_right = tl_right, tl_left
      end

      # if the left line ends at the middle, the left line changes
      # otherwise this will be false and the right line will change
      switch_left = line_left.p2 == p2

      # calculate line slopes
      slope_left = line_left.slope
      slope_right = line_right.slope

      c = p1.y             # offset from 0
      height = p3.y - p1.y # triangle height
      mid = p2.y - p1.y    # where the shorter line ends

      # Starting at 0, up to the height, draw scanlines
      0.upto(height) do |y|
        # Get the normalized t value for this height level
        ty = height > 0 ? y / height : 0.0

        # Check if the slope is 0, this would cause a divide by 0
        if slope_left == 0
          # When there is no rise, set the x value directly
          x_left = line_left.p2.x
        else
          x_left = ((y - (line_left.p1.y - p1.y)) / slope_left).round.to_i + line_left.p1.x
        end

        if slope_right == 0
          x_right = line_right.p2.x
          t_right = tl_right.p2.x
        else
          x_right = ((y - (line_right.p1.y - p1.y)) / slope_right).round.to_i + line_right.p1.x
        end

        # Get the normalized t value for this height level
        ty = height > 0 ? y / height : 0.0
        # LERP both texture edges at the y position to create a new line
        tyl =
          if switch_left
            # Line left is the 2 part segment
            if y <= mid
              # still in the first segment (percent over the midpoint)
              mid == 0 ? 0.0 : y / mid
            else
              # in the second part, pecentage of middle to end
              height == 0 ? 0.0 : (y - mid) / (height - mid)
            end
          else
            height == 0 ? 0.0 : y / height
          end

        tyr =
          unless switch_left
            if y <= mid
              mid == 0 ? 1.0 : y / mid
            else
              height == 0 ? 1.0 : (y - mid) / (height - mid)
            end
          else
            height == 0 ? 1.0 : y / height
          end

        texture_line = PF::Line.new(tl_left.lerp(tyl), tl_right.lerp(tyr))

        # Get the width of the scan line
        scan_size = x_right - x_left

        x_left.upto(x_right) do |x|
          # LERP the line between the texture edges
          t = scan_size == 0 ? 0.0 : (x - x_left) / scan_size
          # Multiply the point by the size of the sprite to get the final texture point
          sample_point = texture_line.lerp(t) * sprite.size
          pixel = sprite.sample((sample_point + 0.5).to_i)

          pixel.r = (pixel.r * (color.r / 255)).to_u8
          pixel.g = (pixel.g * (color.g / 255)).to_u8
          pixel.b = (pixel.b * (color.b / 255)).to_u8

          draw_point(x, y + c, pixel)
        end

        # Once we hit the point where a line changes, we need a new slope for that line
        if y == mid
          if switch_left
            line_left = PF::Line.new(p2, p3)
            tl_left = PF::Line.new(t2, t3)
            slope_left = line_left.slope
          else
            line_right = PF::Line.new(p2, p3)
            tl_right = PF::Line.new(t2, t3)
            slope_right = line_right.slope
          end
        end
      end
    end
  end
end
