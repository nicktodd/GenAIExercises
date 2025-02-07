#!/usr/bin/perl

use File::Copy;
#use warnings;

# set the table name and the database engine
$TABLE_NAME = "HistoricalPrices";
$DATABASE_ENGINE = "InnoDB";
$DEFAULT_CHARSET = "latin1";

# set the filename to be processed
$filename = "test.csv";

# open the files to be written to
open(TABLE, ">mysqlCreateSchema.sql") || die "Failed to redirect output";
open(VALUES, ">mysqlInsertValues.sql") || die "Failed to redirect output";

# set the count to zero
$count = 0;

# set the column values to be empty
$Columns_Values = "";

# open the file to be read
open FILE, "$filename" or die $!;

# read the first line of the file to get the field names
my $columns = <FILE>;

# remove carriage return (for Windows, if you have a CR and a LF, you will need to chop twice)
chop $columns;

chop $columns;

# check to see if the field contains a ' - and if so, add a slash \ in front
$columns =~ s/'/\\'/g;

# ...remove the first " and then "," will be our delimiter
$columns =~ s/\"//;
# ...remove the last " from the end of the line so that "," will be our delimiter
chop $columns;

# remove spaces, add an underscore _
$columns =~ s/ /_/g;
#print "$columns\n";

# split first line into individual field names
@Field_Names = split("\",\"",$columns);

# total number of field names
$Field_Names_Count = $#Field_Names;

# add one to the $Field_Names_Count
$Field_Names_Count_Plus_One = $Field_Names_Count + 1;

# start the field count at zero
$field_count = 0;

# create the column names (values) for the "insert into" part of the SQL statement
if ($count == 0)

{

$column_count = 0;

   while ($column_count <= $Field_Names_Count)
   
   {
      if ($column_count < $Field_Names_Count)
   
      {
         $Columns_Values = $Columns_Values . $Field_Names[$column_count] . ", ";
      }
      
      
      if ($column_count == $Field_Names_Count)
   
      {
         $Columns_Values = $Columns_Values . $Field_Names[$column_count];
      }

      $column_count++;
   }
   
# end if ($count == 0)
}

$count = 0;

# continue to parse the rest of the file which contains the data
while (<FILE>)

{

# remove the carriage return
chomp $_;

# remove the first " and then...
$_ =~ s/\"//;

# ...remove the last " from the end of the line so that "," will be our delimiter
chop $_;

# split the first line into what will be used as the column names
@Field_Values = split("\",\"",$_);

while ($field_count <= $Field_Names_Count )

{

   # check to see if the field contains a ' - and if so, add a slash \ in front
   $Field_Values[$field_count] =~ s/'/\\'/g;

         # if a field is blank, set it to zero, and then remove the zero later
         if (length($Field_Values[$field_count]) < 1)
         
         {
            $Field_Values[$field_count] = "0";
         }

         # check to see if the field value contains any alphabet characters
         if ( $Field_Values[$field_count] =~ m/[a-zA-Z]/)
         
         {
               $type[$field_count] = "varchar";
               
               # find the longest length of the data in the column
               if ($length[$field_count] < 'length($Field_Values[$field_count])')
            
               {
                  $length[$field_count] = length($Field_Values[$field_count]);
               }
         }
   
   
   # once a field has been designated as a varchar, we don't need to test it any further
   # as we aren't going to change a varchar field back to a number or decimal field
   if ($type[$field_count] ne "varchar")
   
   {
         # check to see if the field value does not contain any alphabet characters
         if ( $Field_Values[$field_count] =~ m/[^a-zA-Z]/)
   
         {
            # if the field was already determined to be a decimal, then keep it a decimal
            # if not, then set it to be a number
            if ($type[$field_count] ne "decimal")
            
            {
               $type[$field_count] = "int";
               
               # find the longest length of the data in the column
               if ($length[$field_count] lt 'length($Field_Values[$field_count])')
               {
                  $length[$field_count] = length($Field_Values[$field_count]);
               }
            }
         }
   
         # if the field contains numbers and a period
         if ( $Field_Values[$field_count] =~ m/[0-9.]/)
   
         {
               @count_periods = split("\\.",$Field_Values[$field_count]);
               $number_of_periods = $#count_periods;
            
            
            # if there are two periods in the field, then it is a varchar
            if ($number_of_periods > 1)
            
            {
   
            $type[$field_count] = "varchar";
            
         
               # check for the length of the field to make sure we have the highest field length
               if ($length[$field_count] < 'length($Field_Values[$field_count])')
               {
                  $length[$field_count] = length($Field_Values[$field_count]);
               }
   
   
                  # set these values to be zero - in case the previous field contained a decimal number
                  $decimal_length1[$field_count] = "";
                  $decimal_length2[$field_count] = "";
               }
   
            # if there is only one period in the field, then it is a decimal with X number of decimal places
            if ($number_of_periods == 1)
            
            {
               $type[$field_count] = "decimal";
               
               # split the number to find out the length of each side of the decimal
               # example 1234.56 = 4,2
               @split_decimal_number = split("\\.",$Field_Values[$field_count]);
               
               # find the length of each side of the decimal and keep the highest value
               # this is for the number to left of the decimal
               if ($decimal_length1[$field_count] lt length($split_decimal_number[0]))
               
               {
                  $decimal_length1[$field_count] = length($split_decimal_number[0]);
               }
               
               # find the length of each side of the decimal and keep the highest value
               # this is for the number to right of the decimal
               if ($decimal_length2[$field_count] lt length($split_decimal_number[1]))
               
               {
                  $decimal_length2[$field_count] = length($split_decimal_number[1]);
               }
                           
            # end if ($number_of_periods == 1)
            }
   
         # end if ( $Field_Values[$field_count] =~ m/[0-9.]/)
         }
                  
         # if the field contains anything else besides a 0-9 or a period (.)
         if ( $Field_Values[$field_count] =~ m/[^0-9.]/)
         
         {
               $type[$field_count] = "varchar";
   
               # find the longest length of the data in the column
               if ($length[$field_count] lt 'length($Field_Values[$field_count])')
            
               {
                  $length[$field_count] = length($Field_Values[$field_count]);
               }
   
         # end if ( $Field_Values[$field_count] =~ m/[^0-9.]/)         
         }
   
   # end if ($type[$field_count] ne "varchar")
   }
   
   else
   
   {         
   
               # check for the length of the field to make sure we have the highest field length
               if ($length[$field_count] < length($Field_Values[$field_count]))
            
               {
                  $length[$field_count] = length($Field_Values[$field_count]);
               }
   
   
   # end else
   }
   
   
   # uncomment this line if you want to see the data being processed - as well as another line below
   # print "$Field_Values[$field_count] $type[$field_count] $length[$field_count] $decimal_length1[$field_count] $decimal_length2[$field_count] | ";
   
   
         # if a field is blank, we set it to zero earlier, now we remove the zero
         if (length($Field_Values[$field_count]) < 1)
         
         {
            $Field_Values[$field_count] = "";
         }

   
      # create the syntax needed for the "insert into" statement    
      if ($field_count == 0)
      
      {
         print VALUES "insert into $TABLE_NAME ($Columns_Values) \nvalues ('$Field_Values[$field_count]'";
      }
      
         if ($field_count > 0 && $field_count < $Field_Names_Count_Plus_One)
         
         {
            print VALUES ", '$Field_Values[$field_count]'";
         }
         
      $field_count++;
      # end while ($field_count < $Field_Names_Count_Plus_One )
      }
   
         # check for last entry and then start over on next line
         if ($field_count == $Field_Names_Count_Plus_One)
         
         {
            $field_count = 0;
            $count++;
         
            # close the print statement for the column values
            print VALUES ");\n";
         }
   
   # uncomment this line if you want to see the data being processed
   # print "\n";

# end while (<FILE>)
}

# print the create table statement
print TABLE "\n\nCREATE TABLE `$TABLE_NAME` (\n";

$count_columns = 0;

# loop through the columns and print the type and length for each
while ($count_columns < $Field_Names_Count_Plus_One)

{
   # make sure that we don't have a blank field value
   if (length($Field_Names[$count_columns]) > 0)
   
   {
      if ($type[$count_columns] =~ "decimal")
      
      {
         $decimal_field_length = $decimal_length1[$count_columns] + $decimal_length2[$count_columns];
         print TABLE " `$Field_Names[$count_columns]` $type[$count_columns] ($decimal_field_length,$decimal_length2[$count_columns])";
      }
      
      else
      
      {
         print TABLE " `$Field_Names[$count_columns]` $type[$count_columns] ($length[$count_columns])";
      }
   
      if ($count_columns < $Field_Names_Count)
      
      {
         print TABLE ",\n";
      }
      
      if ($count_columns == $Field_Names_Count_Plus_One)
      
      {
         print TABLE "\n\n";
      }
      
   # end if (length($Field_Names[$count_columns]) > 0)
   }

$count_columns++;

# end while ($count_columns < $Field_Names_Count_Plus_One)
}

# print an output to show how many lines were processed
print "Processed $column_count columns and $count lines.\n";

print TABLE "\n) ENGINE=$DATABASE_ENGINE DEFAULT CHARSET=$DEFAULT_CHARSET\n";

print TABLE "\n\n";

close(FILE);

exit;


print "ETL process with additional transformations completed.\n";