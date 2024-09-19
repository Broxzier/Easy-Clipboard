# Easy Clipboard
# Copyright (c) 2024 Hielke Morsink (Broxzier). All rights reserved.

$defaultItems = @(
  "These default items are at the top of the script",
  "Here you can add new items that will already be listed at startup.",
  "Open this file in notepad to edit it.",
  "Put quotation marks ("") before and after the sentence, and end with a comma (,).",
  "If you want to use a "" in the script, you must write it as """".",
  "There should be no comma after the last item in this list, otherwise you will get errors."
)

# Import WPF's presentation module
Add-Type -AssemblyName PresentationFramework
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

$window = New-Object System.Windows.Window
$window.Title = "Easy Clipboard"
$window.Width = 700
$window.Height = 142
$window.WindowStartupLocation = 'CenterScreen'
$window.TopMost = $false

$mainPanel = New-Object System.Windows.Controls.StackPanel
$mainPanel.Margin = '10'

$buttonPanel = New-Object System.Windows.Controls.StackPanel
$buttonPanel.Margin = '0,0,0,0'


function Add-CopyButton {
  param ($text)
  
  $button = New-Object System.Windows.Controls.Button
  $button.Content = $text
  $button.Margin = '0,5,0,0'
  
  # Set the button click event to copy text to clipboard
  $button.Add_Click({
    param ($sender, $e)
    Set-Clipboard -Value $sender.Content
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
  Add-CopyButton -text $line
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
  Write-Host $sender
  $window.Topmost = $sender.IsChecked
})


# Create a TextBox for user input
$textBox = New-Object System.Windows.Controls.TextBox
$textBox.Margin = '0,0,0,10'

$addButton = New-Object System.Windows.Controls.Button
$addButton.Content = "Toevoegen"
$addButton.Width = 150
$addButton.Margin = '0,0,0,10'
$addButton.Add_Click({
  param ($sender, $e)
  $newText = $textBox.Text
  if (-not [string]::IsNullOrEmpty($newText)) {
    Add-CopyButton -text $newText
    $textBox.Clear()
  }
})


# Add input box and add button to the main panel
$mainPanel.Children.Add($toggleTopmostCheckbox)
$mainPanel.Children.Add($textBox)
$mainPanel.Children.Add($addButton)
$mainPanel.Children.Add($buttonPanel)

$window.Content = $mainPanel


# Show the window
$window.ShowDialog()
