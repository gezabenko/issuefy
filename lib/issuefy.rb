# Copyright (c) 2013 Martin Abente Lahaye. - martin.abente.lahaye@gmail.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA
#

require 'spreadsheet'

class IssuefyErrorTracker < Exception
end

class IssuefyErrorUser < Exception
end

class IssuefyErrorValue < Exception
end

class IssuefyErrorParent < Exception
end

class IssuefyErrorIssue < Exception
end

class IssuefyErrorIssueEmpty < Exception
end

class IssuefyErrorActivity < Exception
end

class IssuefyErrorDate < Exception
end

class IssuefyErrorHour < Exception
end

module Issuefy

  def self.parse_parent(cell)
    return nil if cell.nil?
    parent = Issue.find_by_id(cell) || Issue.find_by_subject(cell)
    raise IssuefyErrorParent, cell if parent.nil?
    parent.id
  end

  def self.parse_issue(cell)
    raise IssuefyErrorIssueEmpty, cell if cell.nil?
    issue = Issue.find_by_id(cell)
    raise IssuefyErrorIssue, cell if issue.nil?
    issue.id
  end

  def self.parse_tracker(cell)
    return nil if cell.nil?
    tracker = Tracker.find_by_name(cell.strip)
    raise IssuefyErrorTracker, cell if tracker.nil?
    tracker
  end

  def self.parse_user_or_group(cell)
    return nil if cell.nil?
    user = User.find_by_login(cell.strip)
    group = Group.find_by_lastname(cell.strip) if user.nil? 
    raise IssuefyErrorUser, cell if user.nil? && group.nil?
    user || group
  end

  def self.parse_activity(cell)
    cell = TimeEntryActivity.first.name if cell.nil?
    activity_id = TimeEntryActivity.find_by_name(cell) 
    raise IssuefyErrorActivity, cell if activity_id.nil?
    activity_id
  end

  def self.parse_date(cell)
    return nil if cell.nil?
    return DateTime.strptime(cell.strip, "%d/%m/%Y") rescue raise IssuefyErrorDate, cell if cell.class == String
    cell
  end

  def self.parse_text(cell)
    return nil if cell.nil?
    cell.strip
  end

  def self.parse_number(cell)
    return nil if cell.nil?
    Float(cell) rescue raise IssuefyErrorValue, cell
  end

  def self.parse_file(file, project, user, file_type)

    book = Spreadsheet.open(file.path)
    sheet = book.worksheet(0)
    count = 0

    if file_type == "issues"
      # TRACKER = 0
      # ASSIGNED = 1
      # SUBJECT = 2
      # DESC = 3
      # START = 4
      # DUE = 5
      # ESTIMATED = 6
      # PARENT = 7
         
      Issue.where(:project_id => project).transaction do
        sheet.each do |row|
  
          # subject MUST be present
          subject = parse_text(row[2])
          next if subject.nil?
  
          issue = Issue.find_by_subject(subject) || Issue.new
  
          issue.project = project
          issue.author = user
          issue.subject = subject
          issue.tracker = parse_tracker(row[0])
          issue.assigned_to = parse_user_or_group(row[1])
          issue.description = parse_text(row[3])
          issue.start_date = parse_date(row[4])
          issue.due_date = parse_date(row[5])
          issue.estimated_hours = parse_number(row[6])
          issue.parent_issue_id = parse_parent(row[7])
  
          issue.save!
  
          count += 1
        end
      end
      count

    else
      # ISSUE = 0
      # DATE = 1
      # HOUR = 2
      # ACTIVITY = 3
      # COMMENT = 4
  
      TimeEntry.where(:project_id => project).transaction do
        sheet.each do |row|
          # the next items MUST be presents
          #issue_id = parse_issue(row[0])
          #next if issue_id.nil?

          time_entry = TimeEntry.new
          time_entry.user = user
          time_entry.issue_id = parse_issue(row[0])
          time_entry.spent_on = parse_date(row[1])
          time_entry.hours = parse_number(row[2])
          time_entry.activity = parse_activity(row[3])
          time_entry.comments = parse_text(row[4])
          time_entry.save!
  
          count += 1
        end
      end
      count

    end
  end

end
