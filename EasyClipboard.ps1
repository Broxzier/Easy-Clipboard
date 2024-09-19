# Easy Clipboard
# Copyright (c) 2024 Hielke Morsink (Broxzier). All rights reserved.

$defaultItems = @(
  @(
    "These default items are at the top of the script",
    "This is the text that will actually be copied when you press the first button"
  ),
  @(
    "Here you can add new items that will already be listed at startup.",
    "You pressed the second button"
  ),
  @(
    "Open this file in notepad to edit it.",
    "You pressed the third button"
  ),
  @(
    "Put quotation marks ("") before and after the sentence, and end with a comma (,).",
    "You pressed the fourth button"
  ),
  @(
    "If you want to use a "" in the script, you must write it as """".",
    "You pressed the fifth button"
  ),
  @(
    "There should be no comma after the last item in this list, otherwise you will get errors.",
    "You pressed the sixth button"
  )
)

# Import WPF's presentation module
Add-Type -AssemblyName PresentationFramework
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

$window = New-Object System.Windows.Window
$window.Title = "Easy Clipboard"
$window.Width = 700
$window.Height = 159
$window.WindowStartupLocation = 'CenterScreen'
$window.TopMost = $false

$mainPanel = New-Object System.Windows.Controls.StackPanel
$mainPanel.Margin = '10'

$buttonPanel = New-Object System.Windows.Controls.StackPanel
$buttonPanel.Margin = '0,0,0,0'


function Add-CopyButton {
  param ($name, $text)

  $button = New-Object System.Windows.Controls.Button
  $button.Content = $name
  $button.Tag = $text
  $button.Margin = '0,5,0,0'

  # Set the button click event to copy text to clipboard
  $button.Add_Click({
    param ($sender, $e)
    Set-Clipboard -Value $sender.Tag
  })

  $button.Add_MouseRightButtonUp({
    param ($sender, $e)
    $buttonPanel.Children.Remove($sender)
    $window.Height -= 25
  })

  $buttonPanel.Children.Add($button)
  $window.Height += 25
}


# Add buttons for each predefined line of text
foreach ($line in $defaultItems) {
  Add-CopyButton -name $line[0] -text $line[1]
}


# Checkbox for toggling top-most functionality
$toggleTopmostCheckbox = New-Object System.Windows.Controls.CheckBox
$toggleTopmostCheckbox.Content = "Houdt scherm bovenaan"
$toggleTopmostCheckbox.Width = 150
$toggleTopmostCheckbox.Margin = '0,0,0,10'
$toggleTopmostCheckbox.HorizontalAlignment = 'Right'
$toggleTopmostCheckbox.FontSize = 10
$toggleTopmostCheckbox.IsChecked = $window.Topmost
$toggleTopmostCheckbox.Add_Click({
  param ($sender, $e)
  $window.Topmost = $sender.IsChecked
})


# Create a Grid to hold the name and text input fields horizontally
$nameAndTextGrid = New-Object System.Windows.Controls.Grid
$col1 = New-Object System.Windows.Controls.ColumnDefinition
$col1.Width = "200"
$col2 = New-Object System.Windows.Controls.ColumnDefinition
$col2.Width = "*"
$nameAndTextGrid.ColumnDefinitions.Add($col1)
$nameAndTextGrid.ColumnDefinitions.Add($col2)
$nameAndTextGrid.Margin = '0,0,0,10'

# Create a TextBox for the name input (optional)
$nameBox = New-Object System.Windows.Controls.TextBox
$nameBox.Margin = '0,0,10,0'
$nameBox.Text = "Naam (optioneel)"
$nameBox.Foreground = [System.Windows.Media.Brushes]::Gray
$nameBox.Add_GotFocus({
    if ($nameBox.Text -eq "Naam (optioneel)") {
        $nameBox.Text = ""
        $nameBox.Foreground = [System.Windows.Media.Brushes]::Black
    }
})
$nameBox.Add_LostFocus({
    if ([string]::IsNullOrWhiteSpace($nameBox.Text)) {
        $nameBox.Text = "Naam (optioneel)"
        $nameBox.Foreground = [System.Windows.Media.Brushes]::Gray
    }
})

# Create a TextBox for the text input
$textBox = New-Object System.Windows.Controls.TextBox
$textBox.Text = "Tekst"
$textBox.AcceptsReturn = $true
$textBox.TextWrapping = 'Wrap'
$textBox.Foreground = [System.Windows.Media.Brushes]::Gray
$textBox.Add_GotFocus({
    if ($textBox.Text -eq "Tekst") {
        $textBox.Text = ""
        $textBox.Foreground = [System.Windows.Media.Brushes]::Black
    }
})
$textBox.Add_LostFocus({
    if ([string]::IsNullOrWhiteSpace($textBox.Text)) {
        $textBox.Text = "Tekst"
        $textBox.Foreground = [System.Windows.Media.Brushes]::Gray
    }
})

$addButton = New-Object System.Windows.Controls.Button
$addButton.Content = "Toevoegen"
$addButton.Width = 150
$addButton.Margin = '0,0,0,10'
$addButton.Add_Click({
  param ($sender, $e)
  $text = $textBox.Text
  $name = if (-not [string]::IsNullOrWhiteSpace($nameBox.Text) -and $nameBox.Text -ne "Naam (optioneel)") { 
    $nameBox.Text 
  } else { 
    $text 
  }

  if (-not [string]::IsNullOrEmpty($text) -and $text -ne "Tekst") {
    Add-CopyButton  -name $name -text $text
	$nameBox.Text = "Naam (optioneel)"
    $textBox.Text = "Tekst"
  }
})


# Tooltip label to inform right-click functionality
$rightclickTooltip = New-Object System.Windows.Controls.TextBlock
$rightclickTooltip.Text = "Klik met de rechtermuisknop op een knop om deze te verwijderen"
$rightclickTooltip.HorizontalAlignment = 'Center'
$rightclickTooltip.Margin = '0,0,0,0'
$rightclickTooltip.FontStyle = 'Italic'


# Define the layout
$mainPanel.Children.Add($toggleTopmostCheckbox)
$nameAndTextGrid.Children.Add($nameBox)
[System.Windows.Controls.Grid]::SetColumn($nameBox, 0)
$nameAndTextGrid.Children.Add($textBox)
[System.Windows.Controls.Grid]::SetColumn($textBox, 1)
$mainPanel.Children.add($nameAndTextGrid)
$mainPanel.Children.Add($addButton)
$mainPanel.Children.Add($rightclickTooltip)
$mainPanel.Children.Add($buttonPanel)

$window.Content = $mainPanel


# Show the window
$window.ShowDialog()
