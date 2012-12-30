$(function()
{
    if ($('.message-list').length > 0)
    {
        $("textarea").keypress(function(e)
        {
            if (e.keyCode == 13 && !e.shiftKey)
            {
                e.preventDefault();
                // now call the code to submit your form
                $(this).parent('form').submit();
                return;
            }
        });
    }
});

function fadeInNewMessages()
{
    // fade in new messages
    $('.new-message').each(function()
    {
        $(this).fadeIn();
    });
}

function temporarySpamBlock()
{
    // Disable the ability to post a new message for a second
    if ($('.post-message').attr("disabled"))
    {
        $('.post-message').removeAttr("disabled");
    }
    else
    {
        $('.post-message').attr("disabled", "disabled");
        setTimeout(temporarySpamBlock, 1000);
    }
}