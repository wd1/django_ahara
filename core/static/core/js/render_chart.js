
function dashboard_user_report(id, labels, data) {
    var user_report = document.getElementById(id);
    if (user_report) {
        user_report.height = 150;
        var myChart = new Chart(user_report, {
            type: 'doughnut',
            data: {
                datasets: [{
                    data: data,
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.2)',
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(255, 206, 86, 0.2)',
                        'rgba(75, 192, 192, 0.2)'
                    ],
                    borderColor: [
                        'rgba(255,99,132,1)',
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(75, 192, 192, 1)'
                    ],
                    hoverBackgroundColor: [
                        'rgba(255, 99, 132, 0.5)',
                        'rgba(54, 162, 235, 0.5)',
                        'rgba(255, 206, 86, 0.5)',
                        'rgba(75, 192, 192, 0.5)'
                    ]
                }],
                labels: labels
            },
            options: {
                title: {
                    display: true,
                    fontSize: 20,
                    text: "Current User Distribution",
                },
                legend: {
                    position: 'right',
                    labels: {
                        fontFamily: 'Poppins'
                    }

                },
                responsive: true
            }
        });
    }
}

function dashboard_assign_report(id, labels, data) {
    var ctx = document.getElementById(id);
    var dateFormat = 'MM/YYYY';
    var dateLabels = labels.map(label => {
        var dateString = label.match(/^(\d{2})\/(\d{4})$/);
        var d = new Date( dateString[2], dateString[1]-1);
        return d;
    });
    if (ctx) {
        ctx.height = 150;
        var myChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: dateLabels,
                type: 'line',
                defaultFontFamily: 'Poppins',
                datasets: [{
                    label: "Users",
                    data: data,
                    backgroundColor: 'rgba(255, 99, 132, 0.2)',
                    borderColor: 'rgba(255,99,132,1)',
                    borderWidth: 3,
                    pointStyle: 'circle',
                    pointRadius: 5,
                    pointBorderColor: 'transparent',
                    pointBackgroundColor: 'rgba(255,99,132,1)',
                }]
            },
            options: {
                responsive: true,
                scaleSteps: 1,
                scaleStepWidth: 1,
                tooltips: {
                    mode: 'index',
                    titleFontSize: 12,
                    opacity: 0.5,
                    titleFontFamily: 'Poppins',
                    bodyFontFamily: 'Poppins',
                    cornerRadius: 3,
                    intersect: false,
                },
                legend: {
                    display: false,
                    labels: {
                        usePointStyle: true,
                        fontFamily: 'Poppins'
                    },
                },
                scales: {
                    xAxes: [{
                        display: true,
                        gridLines: {
                            display: false,
                            drawBorder: false
                        },
                        scaleLabel: {
                            display: false,
                            labelString: 'Month'
                        },
                        ticks: {
                            fontFamily: "Poppins"
                        },
                        type: 'time',
                        time: {
                            displayFormats: {
                                quarter: 'MMM YYYY'
                            }
                        }
                    }],
                    yAxes: [{
                        display: true,
                        gridLines: {
                            display: false,
                            drawBorder: false
                        },
                        scaleLabel: {
                            display: true,
                            labelString: 'Value',
                            fontFamily: "Poppins"
                        },
                        ticks: {
                            fontFamily: "Poppins"
                        }
                    }]
                },
                title: {
                    display: true,
                    fontSize: 20,
                    text: 'New Users in Last 12 months'
                }
            }
        });
    }
}